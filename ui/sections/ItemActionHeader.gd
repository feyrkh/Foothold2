extends Section

# Called when the node enters the scene tree for the first time.
func _ready():
	var game_item = get_game_item()
	$MoveLeftButton.connect('pressed', func():Events.move_action_panel.emit(get_action_panel_container(), false))
	$MoveRightButton.connect('pressed', func():Events.move_action_panel.emit(get_action_panel_container(), true))
	if game_item != null:
		game_item.connect('pin_status_changed', pin_status_changed)
		game_item.connect('label_updated', $GameItemLabel.set_text)
		$GameItemLabel.text = get_game_item().get_label()
		if game_item.has_signal('room_size_updated'):
			game_item.connect('room_size_updated', on_room_size_updated)
			on_room_size_updated(game_item.get_room_size(), game_item.get_occupied_room_size())
		elif game_item.has_method('get_furniture_size'):
			render_furniture_desc()

func pin_status_changed(new_status):
	$PinActionPanelButton.set_pressed_no_signal(new_status)

func on_room_size_updated(room_size, occupied_room_size):
	if room_size == 0:
		$RoomSizeLabel.visible = false
	else:
		$RoomSizeLabel.visible = true
		$RoomSizeLabel.text = 'Space: %d/%d' % [room_size - occupied_room_size, room_size]

func render_furniture_desc():
		$RoomSizeLabel.visible = true
		$RoomSizeLabel.text = 'Size: %d' % [get_game_item().get_furniture_size()]

func allow_move_left(allowed):
	$MoveLeftButton.visible = allowed
	
func allow_move_right(allowed):
	$MoveRightButton.visible = allowed

