extends Object
class_name GameItemAware

var game_item:GameItem

func set_game_item(game_item:GameItem):
	self.game_item = game_item

func get_game_item() -> GameItem:
	return game_item
