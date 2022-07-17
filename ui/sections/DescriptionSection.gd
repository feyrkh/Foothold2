extends Section

func _ready():
	var game_item = get_game_item()
	if game_item and game_item.has_method('get_description'):
		self.text = game_item.get_description()
