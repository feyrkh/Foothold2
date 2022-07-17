extends Control
class_name GameItemActions

var game_item:GameItem

func setup_action_panel(game_ui:GameUI, game_item:GameItem):
	self.game_item = game_item
	var label = find_child('GameItemLabel')
	if label:
		label.set_text(game_item.get_label())
		game_item.connect("label_updated", update_label, [label]) 
	var manage_dropdown = find_child('ItemManageDropdown')
	if manage_dropdown:
		manage_dropdown.setup_dropdown(game_ui, game_item)

func update_label(new_label, label_obj):
	label_obj.set_text(new_label)
