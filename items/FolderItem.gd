extends GameItem
class_name FolderItem

func _ready():
	connect('contents_updated', _contents_updated)

func _contents_updated():
	get_closest_nonfolder_parent().emit_signal('contents_updated')

func can_accept_drop(dropped_item:TreeNode):
	var closest_parent = get_closest_nonfolder_parent()
	if dropped_item.get_allowed_owner_lock_id() != null:
		# an item that's locked to this owner can always be moved onto its owner, and never moved onto a non-owner
		return dropped_item.get_allowed_owner_lock_id() == closest_parent.get_owner_lock_id()
	# if the dropped item is already in the owning parent, or in a folder owned by the owning parent, allow the drop
	var dropped_item_parent = dropped_item.get_parent()
	while dropped_item_parent != null:
		if dropped_item_parent == closest_parent:
			return true
		if dropped_item_parent is FolderItem:
			dropped_item_parent = dropped_item_parent.get_parent()
		else:
			break
	return closest_parent.can_accept_drop(dropped_item)

func can_contain_tags(tag_set):
	return get_closest_nonfolder_parent().can_contain_tags(tag_set)

func can_rename():
	return true

func can_delete():
	return true

func can_create_subfolder():
	return true

func get_action_panel_scene_path()->String:
	return "res://items/GameItemActions.tscn"

func get_tags()->Dictionary:
	return {Tags.TAG_FOLDER:true}

func get_allowed_tags()->Dictionary:
	return get_closest_nonfolder_parent().get_allowed_tags()
