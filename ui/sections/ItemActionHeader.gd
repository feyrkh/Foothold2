extends Section

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_game_item() != null:
		get_game_item().connect('pin_status_changed', pin_status_changed)

func pin_status_changed(new_status):
	$PinActionPanelButton.set_pressed_no_signal(new_status)

