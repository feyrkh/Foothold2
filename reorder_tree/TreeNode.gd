extends Node
class_name TreeNode

signal label_updated(new_label)
signal deleting_node(tree_node)
signal contents_updated() # emitted when a child is added or removed
signal parent_updated(old_parent, new_parent) # Moved from one parent to another; either may be null

var tree_item:TreeItem # owner of this metadata
var label=''
var allowed_tags:Dictionary
var tags:Dictionary = {}
# Unique ID for this node which can be checked against other nodes - if a node has an 'allowed_owner_lock_id'
# then it can only be contained by a node with the same 'owner_lock_id'
var owner_lock_id = null 
var allowed_owner_lock_id = null

func init(label):
	self.label = label
	return self

func _ready():
	pass
	
func get_allowed_tags() -> Dictionary:
	return allowed_tags

func get_owner_lock_id():
	return owner_lock_id

func get_allowed_owner_lock_id():
	return allowed_owner_lock_id

func get_tags() -> Dictionary:
	return tags

func get_parent_tree_node() -> TreeNode:
	return tree_item.get_parent().get_metadata(0)

func get_closest_nonfolder_parent() -> TreeNode:
	if !tree_item:
		return null
	var cur_tree_item = tree_item.get_parent()
	while cur_tree_item.get_metadata(0).get_tags().has(Tags.TAG_FOLDER):
		cur_tree_item = cur_tree_item.get_parent()
	return cur_tree_item.get_metadata(0)

func delete(keep_children):
	if keep_children:
		for child in tree_item.get_children():
			child.move_before(tree_item)
	else:
		for child in tree_item.get_children():
			var node = child.get_metadata(0)
			node.delete(false)
			child.call_deferred('free')
	emit_signal('deleting_node', self)
	if self.has_method('on_delete_tree_node'):
		self.on_delete_tree_node()
	var parent_tree_node = get_parent_tree_node()
	tree_item.call_deferred('free')
	parent_tree_node.emit_signal('contents_updated')
	self.queue_free()

# Text to display on the TreeItem this metadata is associated with
func get_label():
	return label

func set_label(new_val):
	label = new_val
	tree_item.set_text(0, label)
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
	if get_allowed_tags() == null or tag_set == null:
		return false
	for tag in tag_set:
		if get_allowed_tags().has(tag):
			return true
	return false
