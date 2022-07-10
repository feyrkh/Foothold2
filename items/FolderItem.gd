extends GameItem
class_name FolderItem

func get_closest_nonfolder_parent():
	var cur_tree_item = tree_item.get_parent()
	while cur_tree_item.get_metadata(0) is FolderItem:
		cur_tree_item = cur_tree_item.get_parent()
	return cur_tree_item.get_metadata(0)

func can_accept_drop(dropped_item:TreeNode):
	return get_closest_nonfolder_parent().can_accept_drop(dropped_item)

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
