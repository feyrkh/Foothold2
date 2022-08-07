extends Section

func _ready():
	refresh()
	$Button.connect('pressed', on_complete_pressed)

func refresh():
	visible = !!get_game_item().completed
	if visible:
		var work_result = get_game_item().get_goal_reward()
		if work_result:
			$Label.text = 'Reward: '+work_result.get_result_description()
		else:
			$Label.text = ''

func on_complete_pressed():
		var work_result:WorkResult = get_game_item().get_goal_reward()
		if work_result:
			work_result.resolve_results()
		get_game_item().delete(true)
