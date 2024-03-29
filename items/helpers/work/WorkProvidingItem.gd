extends GameItem
class_name WorkProvidingItem

var work_task_list:WorkTaskList = WorkTaskList.new(self)

func _ready():
	parent_updated.connect(check_tasks_valid_after_parent_move)
	contents_updated.connect(check_tasks_valid)

func check_tasks_valid_after_parent_move(old_parent, new_parent):
	check_tasks_valid()

func check_tasks_valid():
	work_task_list.check_tasks_valid()

func get_in_progress_work_tasks(requestor:GameItem=null) -> Dictionary:
		return work_task_list.get_in_progress_tasks(requestor)

func get_work_task(work_task_id) -> WorkTask:
	return work_task_list.get_task(work_task_id)

func get_work_task_options(requestor:GameItem) -> Dictionary:
	return {}

func start_work_task(next_task:WorkTaskOption, contributor:GameItem) -> WorkTask:
	if next_task == null:
		return null
	var existing_task = work_task_list.get_task(next_task.get_id())
	if existing_task:
		return existing_task
	var new_task = build_work_task(next_task, contributor)
	if new_task == null:
		push_error('Tried to create new task but it returned null; label=', next_task.get_label(), '; id=', next_task.get_id(), '; sourceId=', next_task.get_source_id())
		return null
	if new_task.get_id() == null:
		new_task.set_id(next_task.get_id())
	if new_task.get_source_id() == null:
		new_task.set_source_id(next_task.get_source_id())
	if new_task.get_task_name() == null:
		new_task.set_task_name(next_task.get_task_name())
	new_task.location_filter = next_task.location_filter
	if new_task.pre_desc == null:
		new_task.pre_desc = next_task.task_description
	if new_task.post_desc == null:
		new_task.post_desc = next_task.task_description
	work_task_list.add_task(new_task)
	new_task.on_task_created()
	return new_task

func build_work_task(next_task:WorkTaskOption, contributor:GameItem) -> WorkTask:
	return null # override in subclasses
