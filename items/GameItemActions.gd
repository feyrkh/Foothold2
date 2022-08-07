extends Control
class_name GameItemActions

var game_item:GameItem

func _ready():
	pass

func get_game_item():
	return game_item

func setup_action_panel(game_ui:GameUI, game_item:GameItem):
	self.game_item = game_item
	var label = find_child('GameItemLabel')
	if label:
		label.set_text(game_item.get_label())
		game_item.connect("label_updated", update_label, [label]) 
	var manage_dropdown = find_child('ItemManageDropdown', true, false)
	if manage_dropdown:
		manage_dropdown.setup_dropdown(game_ui, game_item)

func update_label(new_label, label_obj):
	label_obj.set_text(new_label)

func refresh_action_panel():
	for child in get_children():
		if child.has_method('refresh'):
			child.refresh()

func _can_drop_data(at_position, dropped_item_list):
	return Global.main_tree.check_valid_drop(get_game_item().tree_item, dropped_item_list)

func _drop_data(at_position, dropped_item_list):
	Global.main_tree.drop_data_at_offset(get_game_item().tree_item, 0, dropped_item_list)

func _get_drag_data(at_position):
	var item = get_game_item().tree_item
	var drag_preview = Control.new()
	var label := Label.new()
	label.text = item.get_text(0)
	label.modulate = ReorderTree.DRAG_COLOR
	drag_preview.add_child(label)
		#print('item_region: ', get_item_area_rect(item))
	set_drag_preview(drag_preview)
	return [item]
