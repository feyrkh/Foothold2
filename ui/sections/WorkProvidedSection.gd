extends Section

@onready var list:Tree = find_child("Items") 

func _ready():
	refresh()

func refresh():
	list.clear_items()
	var game_item = get_game_item()
	if game_item and game_item.has_method('get_work_amounts'):
		var work_amounts:Array = game_item.get_work_amounts().values()
		work_amounts.sort_custom(Callable(WorkAmount, 'sort'))
		for work_amount in work_amounts:
			list.add_work_amount(work_amount)
		visible = !work_amounts.is_empty()
	else:
		visible = false
