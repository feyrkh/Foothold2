extends Control
class_name Section

var _game_item:GameItem


func _ready():
	if self.has_method('refresh'):
		self.refresh()

func get_game_item() -> GameItem:
	if !_game_item:
		var actions = get_parent()
		while actions != null and !(actions is GameItemActions):
			actions = actions.get_parent()
		if actions != null:
			_game_item = actions.game_item
		else:
			push_error('Section with no ancestor of type GameItemActions')
		if !_game_item:
			push_error('Section with ancestor of type GameItemActions with a null game_item')
	return _game_item
