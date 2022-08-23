extends VBoxContainer

@onready var list = $Items
var task:WorkTask

func refresh(task:WorkTask):
	if self.task != task:
		if self.task != null: self.task.work_amounts_updated.disconnect(refresh)
		if task != null: task.work_amounts_updated.connect(refresh)
	self.task = task
	
	var work_needed:Array = task.get_work_needed().values()
	var work_provided = task.get_work_amounts()
	work_needed.sort_custom(Callable(WorkAmount, 'sort'))
	# check to see if we have exactly the same work needed as before, in the same order - if so we can just rewrite the work needed/provided fields
	# if not, we have to wipe the whole list and rebuild it. We don't do just do this every time because it breaks the tooltip popups when we do
	var need_full_refresh = work_needed.size() != (list.get_root().get_child_count()-1) # -1 for the header
	if !need_full_refresh:
		# we have the same size lists, let's see if they have the same values
		for i in range(work_needed.size()):
			var needed:WorkAmount = work_needed[i]
			var item:TreeItem = list.get_root().get_child(i)
			if needed.work_type != item.get_metadata(0):
				need_full_refresh = true
				break
			else:
				var provided = work_provided.get(needed.work_type, null)
				list.update_work_amount(needed, provided, item)
	if need_full_refresh:
		list.clear_items()
		for needed in work_needed:
			var provided = work_provided.get(needed.work_type, null)
			list.add_work_amount(needed, provided)
