extends Node
class_name TreeNode

var tree_item:TreeItem # owner of this metadata

func _init(name):
	self.name = name

# Text to display on the TreeItem this metadata is associated with
func get_label():
	return self.name

func can_accept_drop(dropped_item:TreeNode):
	#print('dropped_item: ', dropped_item.get_label(), '; target: ', get_label(), '; dropped_item parent: ', dropped_item.get_parent().get_metadata(0))
	var dti = dropped_item.tree_item
	var dtip = dti.get_parent()
	print('dti: ', dti.get_text(0))
	print('dtip: ', dtip.get_text(0))
	print('me: ', tree_item.get_text(0))
	if dropped_item.tree_item.get_parent() == tree_item:
		# always allow things to be moved around inside a container it's already in
		return true
	return false

func get_drop_preview():
	var drag_preview = Label.new()
	drag_preview.text = get_label()
	return drag_preview
