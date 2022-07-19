extends Section

# Requires GameItem with methods:
# 	get_work_needed(): Returns map of work_type_string -> WorkAmount, shows how much work is remaining
# 	get_work_amounts(): Returns map of work_type_string -> WorkAmount, shows how much work the workers are providing

@onready var list:Tree = find_child("Items") 

func _ready():
	refresh()

func refresh():
	list.clear_items()
	var game_item = get_game_item()
	if game_item and game_item.has_method('get_work_needed'):
		var work_needed:Array = game_item.get_work_needed().values()
		var work_provided = game_item.get_work_amounts()
		work_needed.sort_custom(Callable(WorkAmount, 'sort'))
		for needed in work_needed:
			var provided = work_provided.get(needed.work_type, null)
			list.add_work_amount(needed, provided)
		visible = !work_needed.is_empty()
	else:
		visible = false
