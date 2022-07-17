extends Section

func _ready():
	var game_item = get_game_item()
	if game_item and game_item.has_method('has_more_explore_locations'):
		visible = game_item.has_more_explore_locations() and get_game_item().find_child_items(is_explore_work_party).is_empty()
	find_child('Button').connect('pressed', start_explore_party)

func start_explore_party():
	visible = false
	var existing_explore_party = get_game_item().find_child_items(is_explore_work_party)
	if existing_explore_party:
		return
	var work_party:WorkPartyItem = WorkPartyItem.new("Exploration Party")
	work_party.set_work_types([WorkTypes.EXPLORE])
	work_party.valid_work_target_types = WorkPartyItem.WORK_TARGET_PARENT_ONLY
	var game_item = get_game_item()
	Events.emit_signal('add_game_item', work_party, game_item, true)

func is_explore_work_party(game_item:GameItem)->bool:
	return game_item.has_method('get_work_types') and game_item.get_work_types().has(WorkTypes.EXPLORE)
