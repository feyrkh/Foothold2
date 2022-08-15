extends Section

@onready var items = find_child("Items")

func refresh():
	items.clear_items()
	var stats = get_game_item().get_stats()
	for stat_type in Stats.ALL_STATS:
		var stat = stats[stat_type]
		if stat:
			items.add_stat(stat)
