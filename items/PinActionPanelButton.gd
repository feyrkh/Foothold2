extends TextureButton

# Called when the node enters the scene tree for the first time.
func _ready():
	connect('toggled', set_pinned)
	button_pressed = is_pinned()

func get_game_item():
	var parent = get_parent()
	while parent and !parent.has_method('get_game_item'):
		parent = parent.get_parent()
	if parent:
		return parent.get_game_item()
	else:
		return null

func is_pinned():
	return button_pressed

func set_pinned(is_pinned):
	Events.emit_signal('pin_action_panel', get_game_item(), is_pinned)
