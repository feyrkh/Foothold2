# in-progress task, with specific amounts of work remaining and reward config
extends RefCounted
class_name WorkTask

signal contributors_updated(work_task)
signal work_amounts_updated(work_task)

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
var __contributor_items_cache
var __work_amounts_cache

var total_work_needed:float
var total_work_applied:float
var pre_desc # description it gives before the task is complete
var post_desc # description it gives after the task is complete

static func build_from_config(c:Dictionary):
	var result = WorkTask.new()
	Config.config(result, c)
	return result

func post_config(c):
	var wn = {}
	for k in work_needed:
		wn[k] = WorkAmount.build_from_config(work_needed[k])
	work_needed = wn

func set_work_needed(work_needed:Dictionary):
	self.work_needed = work_needed
	total_work_needed = 0
	total_work_applied = 0
	for work_type in work_needed.keys():
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
	
func on_work_complete(work_party:WorkPartyItem):
	execute_callback(WORK_COMPLETE_CALLBACK)
	if auto_resolve:
		resolve_completion_effects()
	refresh_action_panel()

func resolve_completion_effects():
	if work_result:
		work_result.resolve_results()
	execute_callback(RESOLVE_WORK_CALLBACK)
	if delete_on_resolve:
		delete(true)

func update_percentage_label():
	if !tree_item or !is_instance_valid(tree_item):
		return
	if total_work_needed == 0:
		tree_item.set_text(0, label)
		return
	var pct = (total_work_applied/total_work_needed) * 100
	if pct == 0:
		tree_item.set_text(0, label)
	else:
		tree_item.set_text(0, label+' (%.0f%%)'%[pct])

func apply_effort(worker:WorkAwareItem):
	if is_work_complete():
		Events.disconnect('game_tick', game_tick)
		return
	for work_type in work_amounts:
		var needed:WorkAmount = work_needed.get(work_type)
		var provided:WorkAmount = work_amounts.get(work_type)
		if !needed or !provided:
			continue
		var applied = min(needed.get_total_effort(), provided.get_total_effort())

		if applied >= 0:
			updated = true
			total_work_applied += applied
			refresh_action_panel()
			update_percentage_label()
			needed.apply_effort(applied)
			provided.on_effort_applied(work_type, applied)
			if needed.get_total_effort() < 0.000001:
				work_needed.erase(work_type)
				work_amounts.erase(work_type)
	if is_work_complete():
		emit_signal('work_complete', self)
		tree_item.set_icon(0, load("res://assets/icon/pin-1.png"))
		refresh_action_panel()
		return
	if updated:
		tree_item.set_icon(0, load("res://assets/icon/arrow-right.png"))
	else:
		Events.disconnect('game_tick', game_tick)
		tree_item.set_icon(0, null)

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

func add_contributor_id(contributor_id):
	if contributors == null:
		contributors = {}
	contributors[contributor_id] = 1
	__contributor_items_cache = null
	__work_amounts_cache = null
	contributors_updated.emit(self)
	work_amounts_updated.emit(self)

func remove_contributor_id(contributor_id):
	if contributors == null:
		return
	contributors.erase(contributor_id)
	if contributors.is_empty():
		contributors = null
	__contributor_items_cache = null
	__work_amounts_cache = null
	contributors_updated.emit(self)
	work_amounts_updated.emit(self)

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
	
