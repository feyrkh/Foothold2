extends Section

# Requirements:
# Contained by a GameItem with these functions:
# 	has_more_explore_locations(): returns true if more exploration is possible
# 	get_explore_effort_needed(): returns base effort for the next exploration
# 	get_explore_description(): optional, returns a string description for the exploration before it's complete

func _ready():
	update_visibility()
	find_child('Button').connect('pressed', start_explore_party)

func update_visibility():
	var game_item = get_game_item()
	if game_item and game_item.has_method('has_more_explore_locations'):
		visible = game_item.has_more_explore_locations() and get_game_item().find_child_items(is_explore_work_party).is_empty()

func start_explore_party():
	visible = false
	var game_item = get_game_item()
	var existing_explore_party = game_item.find_child_items(is_explore_work_party)
	if existing_explore_party:
		return
	var work_party:WorkPartyItem = game_item.get_explore_work_party()
	if !work_party:
		game_item.description = "There is nothing left to find!"
		game_item.refresh_action_panel()
	else:
		Factory.place_item(work_party, game_item, true)

func is_explore_work_party(game_item:GameItem)->bool:
	return game_item.has_method('get_work_party_type') and game_item.get_work_party_type() == Tags.WORK_PARTY_EXPLORE
