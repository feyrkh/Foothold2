extends HFlowContainer

func refresh(task:WorkTask):
	for child in get_children():
		child.queue_free()
	var contributors = task.get_contributors()
	for contributor in contributors:
		add_row(contributor)

func add_row(contributor:GameItem):
	var entry = preload('res://ui/work/ContributorsEntry.tscn').instantiate()
	add_child(entry)
	entry.setup(contributor)
	
