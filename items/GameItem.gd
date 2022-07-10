extends TreeNode
class_name GameItem

var allowed_tags = null

func can_contain_tags(tag_set):
	if allowed_tags == null:
		return false
	for tag in tag_set:
		if allowed_tags.has(tag):
			return true
	return false

func can_rename():
	return true

func can_delete():
	return false

func can_create_subfolder():
	return allowed_tags != null

func build_action_panel(game_ui:GameUI):
	var path = get_action_panel_scene_path()
	if path == null:
		return "res://items/GameItemActions.tscn"
	var panel = load(path).instantiate()
	panel.setup_action_panel(game_ui, self)
	return panel

func get_action_panel_scene_path()->String:
	return "res://items/GameItemActions.tscn"
