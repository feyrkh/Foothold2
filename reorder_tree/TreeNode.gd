extends Node
class_name TreeNode

signal label_updated(new_label)

var tree_item:TreeItem # owner of this metadata
var label

func _init(label):
	self.label = label

# Text to display on the TreeItem this metadata is associated with
func get_label():
	return label

func set_label(new_val):
	label = new_val
	emit_signal("label_updated", label)

func can_accept_drop(dropped_item:TreeNode):
	#print('dropped_item: ', dropped_item.get_label(), '; target: ', get_label(), '; dropped_item parent: ', dropped_item.get_parent().get_metadata(0))(0))
	if dropped_item.tree_item.get_parent() == tree_item:
		# always allow things to be moved around inside a container it's already in
		return true
	return false

func get_drop_preview():
	var drag_preview = Label.new()
	drag_preview.text = get_label()
	return drag_preview
