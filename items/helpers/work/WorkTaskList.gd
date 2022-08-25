# Manager for a list of task factories and in-progress tasks
extends RefCounted
class_name WorkTaskList

signal task_list_changed()

var work_target:GameItem
var in_progress_tasks
var __loaded = true

const IGNORE_FIELDS = {'work_target':1}
func get_ignore_field_names():
	return IGNORE_FIELDS

# Set the work target - when we want to start a task, we'll ask the target for the WorkTask instance
# using this ID and the 'build_work_task(work_target.get_id()' function call.
func _init(work_target:GameItem):
	self.work_target = work_target
	Events.post_load_game.connect(post_load_game, ConnectFlags.CONNECT_ONESHOT)

func post_config(c):
	__loaded = false
	if in_progress_tasks != null:
		for k in in_progress_tasks.keys():
			if in_progress_tasks[k] is Dictionary:
				in_progress_tasks[k] = WorkTask.build_from_config(in_progress_tasks[k])
			in_progress_tasks[k].work_resolved.connect(remove_task)

func post_load_game():
	__loaded = true

func check_tasks_valid():
	if !__loaded: return # don't check for task validity on reloading a save game, we might not be done loading all objects yet
	if in_progress_tasks == null: return
	for k in in_progress_tasks.keys():
		var task = in_progress_tasks[k]
		if task != null and is_instance_valid(task):
			task.check_contributors_valid()

func get_task(task_id) -> WorkTask:
	if in_progress_tasks == null:
		return null
	var result = in_progress_tasks.get(task_id, null)
	return result

func add_task(task:WorkTask):
	if in_progress_tasks == null:
		in_progress_tasks = {}
	in_progress_tasks[task.get_id()] = task
	task.work_resolved.connect(remove_task)
	task_list_changed.emit()

func remove_task(task:WorkTask):
	in_progress_tasks.erase(task.get_id())
	task_list_changed.emit()

func filter_task_options(opts, requestor):
	# Given a map of task_id -> WorkTaskOption, remove any task_ids that are already in progress
	if in_progress_tasks != null:
		for k in in_progress_tasks.keys():
			opts.erase(k)
	var allowed_position_relationship = false
	for k in opts.keys():
		var option:WorkTaskOption = opts[k]
		if !WorkTask.allowed_position_relationship(work_target, requestor, option.location_filter):
			opts.erase(k)
	return opts

func get_in_progress_tasks(requestor:GameItem=null) -> Dictionary:
	if requestor == null:
		return in_progress_tasks if in_progress_tasks != null else {}
	else:
		var result = {}
		if in_progress_tasks != null:
			for k in in_progress_tasks.keys():
				if get_task(k).check_allowed_worker(requestor):
					result[k] = in_progress_tasks[k]
		return result
