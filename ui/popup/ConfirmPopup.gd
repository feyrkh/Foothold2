extends PopupPanel

signal ok_button_pressed()

@onready var OkCancelButtons = find_child('OkCancel')

func set_prompt(val):
	find_child('Label').set_text(val)

# Called when the node enters the scene tree for the first time.
func _ready():
	OkCancelButtons.connect('ok_button_pressed', ok)
	OkCancelButtons.connect('cancel_button_pressed', cancel)
	if get_parent() == get_tree().root:
		popup()

func ok():
	emit_signal('ok_button_pressed')
	queue_free()

func cancel():
	queue_free()
