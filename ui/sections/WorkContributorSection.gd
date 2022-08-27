extends Section

var next_task_owner_id
var next_task

@onready var CurrentTaskDisplay = find_child('CurrentTaskDisplay')

func _ready():
	find_child('NextTaskTargetDropdown').setup('<select task source>', populate_next_target_dropdown)
	find_child('NextTaskTargetDropdown').connect('item_selected', next_task_target_selected)
	find_child('NextTaskOptionDropdown').setup('<select task>', populate_next_option_dropdown)
	find_child('NextTaskOptionDropdown').connect('item_selected', next_task_option_selected)
	find_child('StartTaskButton').connect('pressed', start_next_task)
	get_game_item().parent_updated.connect(owner_parent_updated)
	get_game_item().contents_updated.connect(owner_contents_updated)
	CurrentTaskDisplay.task_resolved.connect(refresh)
	CurrentTaskDisplay.task_cancelled.connect(cancel_task)
	refresh()

func owner_parent_updated(old_parent, new_parent):
	check_next_task_still_valid()
	
func owner_contents_updated():
	check_next_task_still_valid()
	
func check_next_task_still_valid():
	if next_task_owner_id and !has_task_options(get_game_item(), IdManager.get_item_by_id(next_task_owner_id)):
		next_task_owner_id = null
		next_task = null
		find_child('NextTaskTargetDropdown').reset()
		find_child('NextTaskOptionDropdown').reset()
		refresh()
	elif next_task and !WorkTask.allowed_position_relationship(IdManager.get_item_by_id(next_task_owner_id), get_game_item(), next_task.location_filter):
		next_task = null
		find_child('NextTaskOptionDropdown').reset()
		refresh()

func refresh():
	var game_item = get_game_item()
	if !game_item or !is_instance_valid(game_item):
		push_error('missing game_item for WorkTaskSection')
		return
	var work_task_owner_id = game_item.get_work_task_owner_id()
	var work_task_id = game_item.get_work_task_id()
	CurrentTaskDisplay.set_task(work_task_owner_id, work_task_id)
	if CurrentTaskDisplay.visible:
		find_child('NextTaskContainer').visible = false
	else:
		find_child('NextTaskContainer').visible = true
		game_item.set_active_work_task_paused(true)
		refresh_next_task()

func refresh_next_task():
	var requestor = get_game_item()
	var current_task_owner = IdManager.get_item_by_id(next_task_owner_id)
	if current_task_owner:
#		find_child('NextTaskTargetLabel').text = current_task_owner.get_label()
		set_next_task_option_visible(true)
#		find_child("NextTaskTargetLabel").text = current_task_owner.get_label()
#		find_child("NextTaskOptionLabel").text = "<select task>"
	else:
#		find_child('NextTaskTargetLabel').text = '<select task source>'
		set_next_task_option_visible(false)
	if next_task:
#		find_child('NextTaskOptionLabel').text = next_task.get_label()
		find_child('NextTaskDescriptionLabel').text = next_task.get_description()
		find_child('StartTaskButton').visible = true
	else:
		find_child('NextTaskDescriptionLabel').text = ''
		find_child('StartTaskButton').visible = false

func set_next_task_option_visible(val):
	find_child('NextTaskOptionHeader').visible = val
	find_child('NextTaskOptionDropdown').visible = val

func has_task_options(requestor, task_source):
	if task_source.has_method('get_in_progress_work_tasks'):
		for task in task_source.get_in_progress_work_tasks(requestor).values():
			if task.is_work_resolved(): continue
			if !task.is_valid_contributor(requestor): continue
			return true
	if task_source.has_method('get_work_task_options'):
		var options = task_source.get_work_task_options(requestor)
		if options != null and options.size() > 0: 
			return true
	return false

func populate_next_target_dropdown():
	var opts = []
	var game_item = get_game_item()
	if has_task_options(game_item, game_item):
		opts.append([game_item.get_label(), game_item])
	var containing_room = game_item.get_closest_nonfolder_parent()
	if has_task_options(game_item, containing_room):
		opts.append([containing_room.get_label(), containing_room])
	var held_items_with_tasks = game_item.find_child_items(func(item): return has_task_options(game_item, item))
	for item in held_items_with_tasks:
		opts.append([item.get_label(), item])
	var sibling_items_with_tasks = game_item.find_sibling_items(func(item): return has_task_options(game_item, item))
	for item in sibling_items_with_tasks:
		opts.append([item.get_label(), item])
	if opts.size() == 0:
		opts.append(['<no activity targets>', null])
	return opts
	
func next_task_target_selected(idx:int, task_source):
	if task_source == null:
		return
	if next_task_owner_id != task_source.get_id():
		next_task_owner_id = task_source.get_id()
		next_task = null
		find_child('NextTaskOptionDropdown').reset()
		find_child('NextTaskOptionDropdown').setup('<select task>', populate_next_option_dropdown, 0)
		refresh_next_task()

func populate_next_option_dropdown():
	var opts = []
	var game_item = get_game_item()
	var tasks_and_options = {}
	tasks_and_options.merge(get_task_options(game_item, IdManager.get_item_by_id(next_task_owner_id)))
	var tasks = tasks_and_options.values()
	tasks.sort_custom(func(a, b): return a.get_label() < b.get_label())
	for task in tasks:
		if (task is WorkTaskOption) or !task.is_work_resolved():
			opts.append([task.get_label(), task])
	if opts.is_empty():
		opts.append(['<no tasks>', null])
	else:
		if !next_task:
			next_task_option_selected(0, opts[0][1])
	return opts
	
func get_task_options(requestor, task_source):
	var results = {}
	if requestor == null or task_source == null:
		return results
	if task_source.has_method('get_work_task_options'):
		results.merge(task_source.get_work_task_options(requestor))
	if task_source.has_method('get_in_progress_work_tasks'):
		results.merge(task_source.get_in_progress_work_tasks(requestor))
	return results

func next_task_option_selected(idx:int, next_task):
	find_child('NextTaskDescriptionLabel').modulate = Color.WHITE
	self.next_task = next_task
	refresh_next_task()

func start_next_task():
	var err_msg = null
	var next_task_owner = IdManager.get_item_by_id(next_task_owner_id)
	if err_msg == null and (next_task_owner == null or !is_instance_valid(next_task_owner)):
		err_msg = 'Task source no longer exists, please choose another.'
	if err_msg == null and (next_task == null or !is_instance_valid(next_task)):
		err_msg = 'Task no longer exists, please choose another'
	if err_msg == null and !WorkTask.allowed_position_relationship(next_task_owner, get_game_item(), next_task.location_filter):
		err_msg = 'Relative locations of '+get_game_item().get_label()+' and '+next_task_owner.get_label()+' makes this task invalid - maybe one of them moved?'
	if err_msg == null and next_task is WorkTaskOption:
		next_task = next_task_owner.start_work_task(next_task, get_game_item())
	if next_task == null:
		err_msg = 'Unable to start task "'+find_child('NextTaskOptionDropdown').selected_text+'" from '+next_task_owner.get_label()
	if err_msg == null and next_task.is_work_resolved():
		err_msg = "This task is already completed and can't be started"
	if err_msg:
		find_child('NextTaskDescriptionLabel').text = err_msg
		find_child('NextTaskDescriptionLabel').modulate = Color.RED
	else:
		find_child('NextTaskDescriptionLabel').modulate = Color.WHITE
		get_game_item().set_current_task(next_task_owner_id, next_task.get_id())
		get_game_item().set_active_work_task_paused(false)
		next_task_owner_id = null
		next_task = null
		find_child('NextTaskTargetDropdown').reset()
		find_child('NextTaskOptionDropdown').reset()
		refresh()

func cancel_task():
	get_game_item().set_current_task(null, null)
	get_game_item().set_active_work_task_paused(true)
	next_task_owner_id = null
	next_task = null
	find_child('NextTaskTargetDropdown').reset()
	find_child('NextTaskOptionDropdown').reset()
	refresh()
	
