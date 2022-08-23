# Manager for a list of task factories and in-progress tasks
extends RefCounted
class_name WorkTaskList

var work_target:GameItem
var in_progress_tasks

const IGNORE_FIELDS = {'work_target':1}
func get_ignore_field_names():
	return IGNORE_FIELDS

# Set the work target - when we want to start a task, we'll ask the target for the WorkTask instance
# using this ID and the 'build_work_task(work_target.get_id()' function call.
func _init(work_target:GameItem):
	self.work_target = work_target

func get_task(task_id) -> WorkTask:
	if in_progress_tasks == null:
		return null
	var result = in_progress_tasks.get(task_id, null)
	if result is Dictionary:
		result = WorkTask.build_from_config(result)
		in_progress_tasks[task_id] = result
	return result

func add_task(task:WorkTask):
	if in_progress_tasks == null:
		in_progress_tasks = {}
	in_progress_tasks[task.get_id()] = task

func filter_task_options(opts, requestor):
	# Given a map of task_id -> WorkTaskOption, remove any task_ids that are already in progress
	if in_progress_tasks != null:
		for k in in_progress_tasks:
			opts.erase(k)
	var allowed_position_relationship = false
	for k in opts:
		var option:WorkTaskOption = opts[k]
		if !WorkTask.allowed_position_relationship(work_target, requestor, option.location_filter):
			opts.erase(k)
	return opts

func get_in_progress_tasks(requestor:GameItem=null):
	if requestor == null:
		return in_progress_tasks if in_progress_tasks != null else {}
	else:
		var result = {}
		if in_progress_tasks != null:
			for k in in_progress_tasks:
				if get_task(k).check_allowed_worker(requestor):
					result[k] = in_progress_tasks[k]
		return result
