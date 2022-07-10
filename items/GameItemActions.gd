extends Control

var game_item:GameItem

func setup_action_panel(game_ui:GameUI, game_item:GameItem):
	self.game_item = game_item
	var label = find_child('GameItemLabel')
	if label:
		label.set_text(game_item.get_label())
		game_item.connect("label_updated", func(new_label): label.set_text(game_item.get_label()))