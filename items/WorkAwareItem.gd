extends WorkProvidingItem
class_name WorkAwareItem

signal active_work_task_paused_updated(paused)

# finish_resolve_item_result args:
#   work_amounts: dictionary of WorkTypes -> float that's used for inherent_work_amounts

var inherent_work_amounts:Dictionary = {}
var work_amounts:Dictionary = {}

var active_work_task_id:
	set(val):
		active_work_task_id = val
		__active_work_task = WorkTask.get_work_task(active_work_task_owner_id, active_work_task_id)
var active_work_task_owner_id:
	set(val):
		active_work_task_owner_id = val
		__active_work_task = WorkTask.get_work_task(active_work_task_owner_id, active_work_task_id)
var __active_work_task
var active_work_task_paused = true:
	set(val):
		if active_work_task_paused != val:
			active_work_task_paused = val
			var task:WorkTask = WorkTask.get_work_task(active_work_task_owner_id, active_work_task_id)
			if task != null:
				task.contributor_work_amount_changed()
			emit_signal('active_work_task_paused_updated', val)
			if val:
				if Events.is_connected('game_tick', work_on_active_task):
					Events.disconnect('game_tick', work_on_active_task)
			else:
				Events.connect('game_tick', work_on_active_task)

func post_config(config:Dictionary):
	if inherent_work_amounts != null:
		for k in inherent_work_amounts.keys():
			var entry_conf = inherent_work_amounts[k]
			inherent_work_amounts[k] = WorkAmount.build_from_config(entry_conf)
	if work_amounts != null:
		for k in work_amounts.keys():
			var entry_conf = work_amounts[k]
			work_amounts[k] = WorkAmount.build_from_config(entry_conf)

func _ready():
	super._ready()
	connect('contents_updated', on_contents_updated)
	connect('parent_updated', _parent_updated)
	update_work_amounts()

func on_contents_updated():
	update_work_amounts()
	check_tasks_valid()

func finish_resolve_item_result(args):
	var amts = args.get('work_amounts', {})
	for k in amts.keys():
		var amt = amts.get(k)
		if amt != null:
			inherent_work_amounts[k] = WorkAmount.new(k, amt, 0.0, {get_id():1}, null, null)
	update_work_amounts()

func _parent_updated(old_parent, new_parent):
	update_work_amounts()
	check_tasks_valid()

func update_specific_work_amount(work_type):
	var work_providing_items = get_work_helpers()
	var work_amount = inherent_work_amounts.get(work_type, null)
	if work_amount != null:
		if work_amount is WorkAmount:
			work_amount = WorkAmount.copy(work_amount)
		else:
			# hopefully it's an integer
			work_amount = WorkAmount.new(work_type, work_amount, 0.0, {get_id():1}, null, null)
	for equip in work_providing_items:
		var equip_work_amounts = equip.get_work_amounts()
		var added_work_amount = equip_work_amounts.get(work_type)
		if added_work_amount:
			if !work_amount:
				work_amount = added_work_amount
			else:
				work_amount.add(added_work_amount)
	if work_amount == null:
		work_amounts.erase(work_type)
	else:
		work_amounts[work_type] = work_amount
	update_parent_work_amounts()
	var task = get_active_work_task()
	if task != null:
		task.contributor_work_amount_changed()
	refresh_action_panel()
	
func update_work_amounts():
	var work_providing_items = get_work_helpers()
	var found_work_amounts = {}
	for k in inherent_work_amounts.keys():
		found_work_amounts[k] = WorkAmount.copy(inherent_work_amounts[k])
		found_work_amounts[k].helper_ids_used[get_id()] = 1
	for equip in work_providing_items:
		var equip_work_amounts = equip.get_work_amounts()
		for k in equip_work_amounts.keys():
			var added_work_amount = equip_work_amounts[k]
			if !found_work_amounts.has(k):
				found_work_amounts[k] = added_work_amount
			else:
				found_work_amounts[k].add(added_work_amount)
			found_work_amounts[k].helper_ids_used[equip.get_id()] = 1
	work_amounts = found_work_amounts
	update_parent_work_amounts()
	var task = get_active_work_task()
	if task != null:
		task.contributor_work_amount_changed()
	refresh_action_panel()

func update_parent_work_amounts():
	var closest_parent = get_closest_nonfolder_parent()
	if closest_parent and closest_parent.has_method('update_work_amounts'):
		closest_parent.update_work_amounts()

func get_work_helpers():
	return find_child_items(_is_work_helper) # By default, anything in a WorkAwareItem's inventory that has a get_work_amount method can help

func _is_work_helper(game_item) -> bool:
	return game_item.has_method('get_work_amount')

func get_work_amounts() -> Dictionary: # string->WorkAmount
	if work_amounts.size() < inherent_work_amounts.size():
		update_work_amounts()
	return work_amounts
	
func get_work_amount(work_type:String) -> WorkAmount:
	return work_amounts.get(work_type, null)

func get_work_task_id():
	return active_work_task_id

func get_work_task_owner_id():
	return active_work_task_owner_id

func set_active_work_task_owner_id(val):
	active_work_task_owner_id = val

func get_work_task_paused()->bool:
	return active_work_task_paused

func set_active_work_task_paused(val:bool):
	active_work_task_paused = val
	if val or !get_active_work_task():
		self.set_label_suffix('work', null)
	else:
		self.set_label_suffix('work', get_active_work_task().get_label_suffix())

func get_active_work_task():
	if __active_work_task == null and active_work_task_id != null:
		__active_work_task = WorkTask.get_work_task(active_work_task_owner_id, active_work_task_id)
	return __active_work_task

func set_current_task(next_task_owner_id, next_task_id):
	if next_task_owner_id == active_work_task_owner_id and next_task_id == active_work_task_id:
		return
	var task = WorkTask.get_work_task(active_work_task_owner_id, active_work_task_id)
	if task != null:
		task.remove_contributor_id(get_id())
	active_work_task_owner_id = next_task_owner_id
	active_work_task_id = next_task_id
	task = WorkTask.get_work_task(active_work_task_owner_id, active_work_task_id)
	if task != null:
		task.add_contributor_id(get_id())
		self.set_label_suffix('work', task.get_label_suffix())
	else:
		self.set_label_suffix('work', null)
	__active_work_task = task

func on_work_applied_to_current_task(task:WorkTask):
	self.set_label_suffix('work', task.get_label_suffix())

func clear_active_task(calling_task):
	set_current_task(null, null)

func work_on_active_task():
	if !active_work_task_paused and get_active_work_task() != null:
		get_active_work_task().apply_effort(self)
	
