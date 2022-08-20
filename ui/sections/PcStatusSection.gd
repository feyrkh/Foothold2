extends Section

@onready var list:Tree = find_child("Items") 

func _ready():
	get_game_item().connect('status_updated', refresh)
	refresh()

func refresh():
	list.clear_items()
	var game_item = get_game_item()
	list.add_status_item('hp', game_item.hp, game_item.get_max_hp(), game_item.get_hp_regen())
	list.add_status_item('focus', game_item.focus, game_item.get_max_focus(), game_item.get_focus_regen())
