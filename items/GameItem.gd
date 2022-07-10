extends TreeNode
class_name GameItem

func can_rename():
	return true

func can_delete():
	return false

func can_create_subfolder():
	return !(super.get_allowed_tags().is_empty())

func build_action_panel(game_ui:GameUI):
	var path = get_action_panel_scene_path()
	if path == null:
		return "res://items/GameItemActions.tscn"
	var panel = load(path).instantiate()
	panel.setup_action_panel(game_ui, self)
	return panel

func get_action_panel_scene_path()->String:
	return "res://items/GameItemActions.tscn"
