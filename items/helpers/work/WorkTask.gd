# in-progress task, with specific amounts of work remaining and reward config
extends RefCounted
class_name WorkTask

signal contributors_updated(work_task)
signal work_amounts_updated(work_task)
signal work_complete(work_task)
signal work_resolved(work_task)

const LOCATION_SELF = 1 # used to filter work tasks that can only be started by their source object, ex: meditation
const LOCATION_SHARED_ROOM = 2 # used to filter tasks that can only be started if the worker shares a room with the source object, ex: exercise with equipment
const LOCATION_INSIDE = 4 # used to filter tasks that can only be started if the worker is inside the source object, ex: explore an area
const LOCATION_HELD = 8 # used to filter tasks that can only be started if the worker is holding the source object, ex: consuming a single-use item?
const DEFAULT_LOCATION_FILTER = LOCATION_SELF | LOCATION_SHARED_ROOM | LOCATION_INSIDE | LOCATION_HELD

var task_source_id # ID of the GameItem that produces this task
var task_id # ID of the task inside the task source, calling IdManager.get_game_item(task_source_id).get_task(task_id) should return this object
var work_result:WorkResult = WorkResult.new()
var work_needed:Dictionary = {} # WorkTypes -> WorkAmount
var task_name
var location_filter = DEFAULT_LOCATION_FILTER
var contributors
var max_contributors:int = 99
var auto_resolve = false
var __contributor_items_cache
var __work_amounts_cache
var resolved:bool

var total_work_needed:float
var total_work_applied:float
var pre_desc # description it gives before the task is complete
var post_desc # description it gives after the task is complete

var __result_connected_contributors = {}

static func build_from_config(c:Dictionary):
	var result = WorkTask.new()
	Config.config(result, c)
	Events.post_load_game.connect(result.post_load_game, ConnectFlags.CONNECT_ONESHOT)
	return result

func post_config(config:Dictionary):
	if work_needed != null:
		for k in work_needed.keys():
			var entry_conf = work_needed[k]
			work_needed[k] = WorkAmount.build_from_config(entry_conf)
	work_result = WorkResult.build_from_config(config.get('work_result', null))

func post_load_game():
	if contributors != null:
		for k in contributors:
			var contributor:WorkAwareItem = IdManager.get_item_by_id(k)
			if !contributor:
				push_error('Failed to find contributor to task ', task_name, '(', task_id, ') in post_load_game: ', k)
				continue
			work_resolved.connect(contributor.clear_active_task)
			work_result_contributor_connect(contributor)
				

func work_result_contributor_connect(contributor:WorkAwareItem):
	if work_result != null and contributor != null:
		if !__result_connected_contributors.has(contributor._item_id):
			var callback = contributor_pause_or_resume.bind(contributor)
			__result_connected_contributors[contributor._item_id] = callback
			contributor.active_work_task_paused_updated.connect(callback)

func work_result_contributor_disconnect(contributor:WorkAwareItem):
	if work_result != null and contributor != null:
		var callback = __result_connected_contributors.get(contributor._item_id)
		__result_connected_contributors.erase(contributor._item_id)
		if callback != null:
			contributor.active_work_task_paused_updated.disconnect(callback)

func contributor_pause_or_resume(paused, contributor):
	if !paused:
		work_result.resolve_work_start_results(contributor.get_id())
	else:
		work_result.resolve_work_stop_results(contributor.get_id())

func set_work_needed(work_needed:Dictionary):
	self.work_needed = work_needed
	total_work_needed = 0
	total_work_applied = 0
	for work_type in work_needed.keys():
		if !(work_needed[work_type] is WorkAmount):
			work_needed[work_type] = WorkAmount.new(work_type, work_needed[work_type], 0, {})
		total_work_needed += work_needed[work_type].get_total_effort()

func get_work_needed():
	return work_needed

func get_work_amounts()->Dictionary:
	if __work_amounts_cache == null:
		var result = {}
		var workers = get_contributors()
		for work_type in get_work_needed().keys():
			var total_amt:WorkAmount
			for worker in workers:
				if worker.active_work_task_paused:
					continue
				var amt = worker.get_work_amount(work_type)
				if amt != null:
					if total_amt == null: 
						total_amt = WorkAmount.copy(amt)
					else:
						total_amt.add(amt)
			if total_amt != null:
				result[work_type] = total_amt
		__work_amounts_cache = result
	return __work_amounts_cache

func is_work_complete()->bool:
	return work_needed == null || work_needed.is_empty()

func resolve_completion_effects():
	resolved = true
	if work_result:
		work_result.resolve_results()
	work_resolved.emit(self)

func is_work_resolved()->bool:
	return resolved

func apply_effort(worker:WorkAwareItem):
	if is_work_complete():
		return
	var work_amounts = worker.get_work_amounts()
	for work_type in work_amounts:
		var needed:WorkAmount = work_needed.get(work_type)
		var provided:WorkAmount = work_amounts.get(work_type)
		if !needed or !provided:
			continue
		var applied = min(needed.get_total_effort(), provided.get_total_effort())
		if applied >= 0:
			total_work_applied += applied
			needed.apply_effort(applied)
			provided.on_effort_applied(work_type, applied)
			if needed.get_total_effort() < 0.000001:
				work_needed.erase(work_type)
				work_amounts.erase(work_type)
	if is_work_complete():
		work_complete.emit(self)
		if work_result != null and contributors != null:
			for contributor_id in contributors:
				work_result.resolve_work_stop_results(contributor_id)
		if auto_resolve:
			resolve_completion_effects()
		return

func set_description(pre_complete, post_complete):
	pre_desc = pre_complete
	post_desc = post_complete

func get_id():
	return task_id

func set_id(val):
	task_id = val
	
func check_allowed_worker(worker):
	if !allowed_position_relationship(IdManager.get_item_by_id(task_source_id), worker, location_filter):
		return false
	# TODO: worker is capable of the kind of work we need?
	# TODO: are there too many workers already?
	return true

static func allowed_position_relationship(work_target:GameItem, requestor:GameItem, location_filter):
	if work_target == null or requestor == null:
		return false
	if location_filter & LOCATION_SELF:
		if work_target == requestor:
			return true
	if location_filter & LOCATION_SHARED_ROOM:
		if work_target.find_sibling_items(func(item): return item == requestor).size() > 0:
			return true
	if location_filter & LOCATION_INSIDE:
		if work_target.find_child_items(func(item): return item == requestor).size() > 0:
			return true
	if location_filter & LOCATION_HELD:
		if requestor.find_child_items(func(item): return item == requestor).size() > 0:
			return true
	return false

func get_label():
	return task_name

func get_description():
	if total_work_needed > total_work_applied:
		return pre_desc if pre_desc != null else ''
	else:
		return post_desc if post_desc != null else ''

func is_valid_contributor(contributor:GameItem) -> bool:
	return max_contributors > get_contributors().size()

func add_contributor_id(contributor_id):
	if work_result != null:
		var contributor:WorkAwareItem = IdManager.get_item_by_id(contributor_id)
		if !contributor:
			push_error('Failed to find contributor to task ', task_name, '(', task_id, ') in add_contributor_id: ', contributor_id)
		else:
			work_result_contributor_connect(contributor)
	if contributors == null:
		contributors = {}
	contributors[contributor_id] = 1
	__contributor_items_cache = null
	__work_amounts_cache = null
	work_resolved.connect(IdManager.get_item_by_id(contributor_id).clear_active_task)
	contributors_updated.emit(self)
	work_amounts_updated.emit(self)

func remove_contributor_id(contributor_id):
	if work_result != null:
		work_result.resolve_work_stop_results(contributor_id)
		var contributor:WorkAwareItem = IdManager.get_item_by_id(contributor_id)
		if !contributor:
			push_error('Failed to find contributor to task ', task_name, '(', task_id, ') in remove_contributor_id: ', contributor_id)
		else:
			work_result_contributor_disconnect(contributor)
	if contributors == null:
		return
	contributors.erase(contributor_id)
	if contributors.is_empty():
		contributors = null
	__contributor_items_cache = null
	__work_amounts_cache = null
	work_resolved.disconnect(IdManager.get_item_by_id(contributor_id).clear_active_task)
	contributors_updated.emit(self)
	work_amounts_updated.emit(self)

func check_contributors_valid():
	if contributors == null: return
	for contributor in contributors:
		if !allowed_position_relationship(IdManager.get_item_by_id(task_source_id), IdManager.get_item_by_id(contributor), location_filter):
			var contributor_item = IdManager.get_item_by_id(contributor)
			if contributor_item != null:
				contributor_item.set_current_task(null, null)
			else:
				remove_contributor_id(contributor)

func contributor_work_amount_changed():
	__work_amounts_cache = null
	work_amounts_updated.emit(self)

func get_contributors()->Array[GameItem]:
	if contributors == null:
		return []
	if __contributor_items_cache == null:
		__contributor_items_cache = contributors.keys() \
			.map(func(id):return IdManager.get_item_by_id(id)) \
			.filter(func(item):return item != null)
		__contributor_items_cache.sort_custom(func(a, b): return a.get_label() < b.get_label())
	return __contributor_items_cache

func set_work_result(work_result:WorkResult):
	self.work_result = work_result

func get_source_id():
	return task_source_id

func set_source_id(val):
	task_source_id = val

func get_task_name():
	return task_name

func set_task_name(val):
	task_name = val

static func get_work_task(task_source_id, task_id)->WorkTask:
	if task_id == null:
		return null
	var task_source = IdManager.get_item_by_id(task_source_id)
	if task_source == null || !task_source.has_method('get_work_task'): return null
	var task = task_source.get_work_task(task_id)
	if task == null || !is_instance_valid(task): return null
	return task
	
