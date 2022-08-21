extends Section

var next_task_owner_id
var next_task

func _ready():
	find_child('NextTaskTargetButton').connect('pressed', popup_next_task_target_menu)
	find_child('NextTaskTargetDropdownMenu').connect('id_pressed', next_task_target_selected)
	find_child('NextTaskOptionButton').connect('pressed', popup_next_task_option_menu)
	find_child('NextTaskOptionDropdownMenu').connect('id_pressed', next_task_option_selected)
	get_game_item().parent_updated.connect(owner_parent_updated)
	get_game_item().contents_updated.connect(owner_contents_updated)
	refresh()

func owner_parent_updated(old_parent, new_parent):
	check_next_task_still_valid()
	check_current_task_still_valid()
	
func owner_contents_updated():
	check_next_task_still_valid()
	check_current_task_still_valid()
	
func check_next_task_still_valid():
	if next_task_owner_id and !has_task_options(get_game_item(), IdManager.get_item_by_id(next_task_owner_id)):
		next_task_owner_id = null
		next_task = null
		refresh()
	elif next_task and !WorkTask.allowed_position_relationship(IdManager.get_item_by_id(next_task_owner_id), get_game_item(), next_task.location_filter):
		next_task = null
		refresh()

func check_current_task_still_valid():
	pass

func refresh():
	var game_item = get_game_item()
	if !game_item or !is_instance_valid(game_item):
		push_error('missing game_item for WorkTaskSection')
		return
	var work_task_owner_id = game_item.get_active_work_task_owner_id()
	var work_task_id = game_item.get_active_work_task_id()
	if work_task_owner_id != null and work_task_id != null:
		find_child('ActiveTaskContainer').visible = true
		find_child('NextTaskContainer').visible = false
		refresh_current_task(work_task_owner_id, work_task_id)
	else:
		find_child('ActiveTaskContainer').visible = false
		find_child('NextTaskContainer').visible = true
		game_item.set_active_work_task_paused(true)
		refresh_next_task()

func refresh_current_task(work_task_owner_id, work_task_id):
	var work_task_owner = IdManager.get_item_by_id(work_task_owner_id)
	if !work_task_owner:
		push_error('missing work_task_owner for WorkTaskSection of item ', get_game_item().get_label())
		return
	var work_task:WorkTask = work_task_owner.get_active_work_task(work_task_id)
	if work_task == null:
		push_error('missing work_task for WorkTaskSection of item ', get_game_item().get_label(), '; task_owner=', work_task_owner_id, '; task_id=', work_task_id)
		return
	find_child('ActiveTaskLabel').text = work_task.task_name
	find_child('ActiveTaskDescription').text = work_task.task_description
	find_child('ResumeTaskButton').visible = work_task_owner.get_active_work_task_paused()
	find_child('PauseTaskButton').visible = !work_task_owner.get_active_work_task_paused()

func refresh_next_task():
	var requestor = get_game_item()
	var current_task_owner = IdManager.get_item_by_id(next_task_owner_id)
	if current_task_owner:
		find_child('NextTaskTargetLabel').text = current_task_owner.get_label()
		set_next_task_option_visible(true)
		find_child("NextTaskTargetLabel").text = current_task_owner.get_label()
		find_child("NextTaskOptionLabel").text = "<select task>"
	else:
		find_child('NextTaskTargetLabel').text = '<select task source>'
		set_next_task_option_visible(false)
	if next_task:
		find_child('NextTaskOptionLabel').text = next_task.get_label()
		find_child('NextTaskDescriptionLabel').text = next_task.get_description()
		find_child('StartTaskButton').visible = true
	else:
		find_child('NextTaskDescriptionLabel').text = ''
		find_child('StartTaskButton').visible = false

func set_next_task_option_visible(val):
	find_child('NextTaskOptionHeader').visible = val
	find_child('NextTaskOptionContainer').visible = val

func has_task_options(requestor, task_source):
	if task_source.has_method('get_in_progress_work_tasks'):
		if task_source.get_in_progress_work_tasks(requestor).size() > 0:
			return true
	if task_source.has_method('get_work_task_options'):
		var options = task_source.get_work_task_options(requestor)
		if options != null and options.size() > 0: 
			return true
	return false

func popup_next_task_target_menu():
	var popup:PopupMenu = find_child('NextTaskTargetDropdownMenu')
	var game_item = get_game_item()
	popup.clear()
	if has_task_options(game_item, game_item):
		popup.add_item(game_item.get_label())
		popup.set_item_metadata(-1, game_item)
	var containing_room = game_item.get_closest_nonfolder_parent()
	if has_task_options(game_item, containing_room):
		popup.add_item(containing_room.get_label())
		popup.set_item_metadata(-1, containing_room)
	var held_items_with_tasks = game_item.find_child_items(func(item): return has_task_options(game_item, item))
	for item in held_items_with_tasks:
		popup.add_item(item.get_label())
		popup.set_item_metadata(-1, item)
	var sibling_items_with_tasks = game_item.find_sibling_items(func(item): return has_task_options(game_item, item))
	for item in sibling_items_with_tasks:
		popup.add_item(item.get_label())
		popup.set_item_metadata(-1, item)
	if popup.item_count == 0:
		popup.add_item('<no activity targets>')
	var button = find_child('NextTaskTargetButton')
	var label = find_child('NextTaskTargetLabel')
	popup.min_size.x = label.size.x + button.size.x
	popup.size.x = popup.min_size.x
	popup.popup_on_screen(button.global_position + Vector2(-label.size.x, button.size.y) )
	
func next_task_target_selected(idx:int):
	var popup:PopupMenu = find_child('NextTaskTargetDropdownMenu')
	var task_source = popup.get_item_metadata(idx)
	if task_source == null:
		return
	if next_task_owner_id != task_source.get_id():
		next_task_owner_id = task_source.get_id()
		next_task = null
		refresh_next_task()


func get_task_options(requestor, task_source):
	var results = {}
	if requestor == null or task_source == null:
		return results
	if task_source.has_method('get_work_task_options'):
		results.merge(task_source.get_work_task_options(requestor))
	if task_source.has_method('get_in_progress_work_tasks'):
		results.merge(task_source.get_in_progress_work_tasks(requestor))
	return results

func popup_next_task_option_menu():
	var popup:ScreenLimitedPopupMenu = find_child("NextTaskOptionDropdownMenu")
	var game_item = get_game_item()
	popup.clear()
	var tasks_and_options = {}
	tasks_and_options.merge(get_task_options(game_item, IdManager.get_item_by_id(next_task_owner_id)))
	var tasks = tasks_and_options.values()
	tasks.sort_custom(func(a, b): return a.get_label() < b.get_label())
	for task in tasks:
		popup.add_item(task.get_label())
		popup.set_item_metadata(-1, task)
	var button = find_child('NextTaskOptionButton')
	var label = find_child('NextTaskOptionLabel')
	popup.min_size.x = label.size.x + button.size.x
	popup.size.x = popup.min_size.x
	popup.popup_on_screen(button.global_position + Vector2(-label.size.x, button.size.y) )

func next_task_option_selected(idx:int):
	var popup:ScreenLimitedPopupMenu = find_child("NextTaskOptionDropdownMenu")
	next_task = popup.get_item_metadata(idx)
	refresh_next_task()
	find_child('StartTaskButton').visible = true
