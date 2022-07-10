extends Node
class_name TreeNode

signal label_updated(new_label)

var tree_item:TreeItem # owner of this metadata
var label
var allowed_tags:Dictionary
var tags:Dictionary = {}
var owner_lock_id = null
var allowed_owner_lock_id = null

func _init(label):
	self.label = label

func get_allowed_tags() -> Dictionary:
	return allowed_tags

func get_owner_lock_id():
	return owner_lock_id

func get_allowed_owner_lock_id():
	return allowed_owner_lock_id

func get_tags() -> Dictionary:
	return tags

# Text to display on the TreeItem this metadata is associated with
func get_label():
	return label

func set_label(new_val):
	label = new_val
	emit_signal("label_updated", label)

func can_accept_drop(dropped_item:TreeNode):
	if dropped_item == self:
		return false
	if dropped_item.tree_item.get_parent() == tree_item:
		# always allow things to be moved around inside a container it's already in
		return true
	if dropped_item.get_allowed_owner_lock_id() != null:
		# an item that's locked to this owner can always be moved onto its owner, and never moved onto a non-owner
		return dropped_item.get_allowed_owner_lock_id() == self.get_owner_lock_id()
	if dropped_item.get_tags().has(Tags.TAG_FOLDER):
		var cur_child:TreeItem = dropped_item.tree_item.get_first_child()
		while cur_child != null:
			if !can_accept_drop(cur_child.get_metadata(0)):
				return false
			cur_child = cur_child.get_next()
		return true
	elif can_contain_tags(dropped_item.get_tags()):
		return true
	return false

func get_drop_preview():
	var drag_preview = Label.new()
	drag_preview.text = get_label()
	return drag_preview

func can_contain_tags(tag_set):
	if allowed_tags == null or tag_set == null:
		return false
	for tag in tag_set:
		if allowed_tags.has(tag):
			return true
	return false
