extends Section

@export var label:String = ""
@export var collapse_id:String = ""

func _ready():
	find_child("Label").set_text(label)
	var button = find_child("Button")
	button.button_pressed = CollapseManager.get_collapsed(get_game_item().get_id(), collapse_id)
	button.connect("toggled", update_collapsed)
	call_deferred('refresh_collapsed', button.button_pressed)

func set_collapsed(collapsed):
	find_child("Button").button_pressed = collapsed

func update_collapsed(collapsed):
	CollapseManager.set_collapsed(get_game_item().get_id(), collapse_id, collapsed)
	refresh_collapsed(collapsed)

func refresh_collapsed(collapsed):
	var idx = get_index() + 1
	if get_parent().get_child_count() > idx:
		var next_child = get_parent().get_child(idx)
		next_child.visible = !collapsed
