extends HFlowContainer

func refresh(task:WorkTask):
	var show_pause_button = !task.is_work_complete()
	for child in get_children():
		child.queue_free()
	var contributors = task.get_contributors()
	for contributor in contributors:
		add_row(contributor, show_pause_button)

func add_row(contributor:GameItem, show_pause_button:bool):
	var entry = preload('res://ui/work/ContributorsEntry.tscn').instantiate()
	add_child(entry)
	entry.setup(contributor, show_pause_button)
	
