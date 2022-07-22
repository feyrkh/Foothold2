extends GameItemActions

func _ready():
	super._ready()
	find_child("WorkCompleteButton").connect('pressed', on_work_complete_pressed)
	refresh_action_panel()

func refresh_action_panel():
	find_child("WorkNeededSection").refresh()
	find_child("DescriptionSection").refresh()
	if !game_item.auto_resolve and game_item.work_needed.is_empty():
		find_child("WorkCompleteButton").visible = true
	else:
		find_child("WorkCompleteButton").visible = false

func on_work_complete_pressed():
	game_item.resolve_completion_effects()
