extends GameItem
class_name WorkProvidingItem

var work_task_list:WorkTaskList = WorkTaskList.new(self)
func get_in_progress_work_tasks(requestor:GameItem=null) -> Dictionary:
		return work_task_list.get_in_progress_tasks(requestor)

func get_active_work_task(work_task_id) -> WorkTask:
	return work_task_list.in_progress_tasks.get(work_task_id, null)

func get_work_task_options(requestor:GameItem) -> Dictionary:
	return {}

