extends MarginContainer

func set_contents(contents):
	find_child('InnerContainer').add_child(contents)
	contents.connect('tree_exiting', queue_free)

func on_node_deleted(node:TreeNode):
	queue_free()
