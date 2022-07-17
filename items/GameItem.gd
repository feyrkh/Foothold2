extends TreeNode
class_name GameItem

var _item_id

func get_id():
	if _item_id == null:
		_item_id = IdManager.get_next_id()
	return _item_id

func can_rename():
	return true

func can_delete():
	return false

func can_create_subfolder():
	return !(super.get_allowed_tags().is_empty())

func build_action_panel(game_ui):
	var path = get_action_panel_scene_path()
	if path == null:
		return "res://items/GameItemActions.tscn"
	var panel = load(path).instantiate()
	panel.setup_action_panel(game_ui, self)
	return panel

func get_action_panel_scene_path()->String:
	return "res://items/GameItemActions.tscn"

func find_sibling_items(filter_func:Callable, deep=false)->Array[GameItem]:
	var parent_item = tree_item.get_parent().get_metadata(0)
	if !parent_item:
		return []
	return parent_item.find_child_items(filter_func, false)

func find_child_items(filter_func:Callable, deep=false):
	var results:Array[GameItem] = []
	if !tree_item or !tree_item.get_child_count():
		return results
	var tree_items = tree_item.get_children()
	for tree_item in tree_items:
		var game_item = tree_item.get_metadata(0)
		if filter_func.call(game_item):
			results.append(game_item)
		if deep or game_item.get_tags().has(Tags.TAG_FOLDER):
			results.append_array(game_item.find_child_items(filter_func, deep))
	return results
