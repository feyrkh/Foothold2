extends MarginContainer

func set_contents(contents):
	find_child('InnerContainer').add_child(contents)
	contents.connect('tree_exiting', queue_free)
