extends HBoxContainer

@export var label:String = ""

func _ready():
	find_child("Label").set_text(label)
	find_child("Button").connect("toggled", update_collapsed)
	update_collapsed(find_child("Button").button_pressed)

func set_collapsed(collapsed):
	find_child("Button").button_pressed = collapsed

func update_collapsed(collapsed):
	var idx = get_index()
	idx += 1
	if get_parent().get_child_count() > idx:
		get_parent().get_child(idx).visible = !collapsed
