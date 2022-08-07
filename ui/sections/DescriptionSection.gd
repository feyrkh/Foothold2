extends Section

func _ready():
	refresh()
	get_game_item().connect('description_updated', description_updated)

func refresh():
	var game_item = get_game_item()
	if game_item and game_item.has_method('get_description'):
		var desc = game_item.get_description()
		if desc != null:
			self.text = game_item.get_description()
			visible = true
		else:
			visible = false
	
func description_updated(game_item):
	refresh()
