extends GameItem
class_name Goal

var description = "An unknown goal"
var data = {}
var important_items = {} # list of keys

const SELF_TAGS = {Tags.TAG_GOAL:true}
const ALLOWED_TAGS = {}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS

func _ready():
	super._ready()
	Events.connect('goal_data', _on_goal_data)
	Events.connect('goal_progress', _on_goal_progress)
	Events.connect('goal_item', register_important_item)

func _on_goal_data(goal_id, data_key, data_value):
	if goal_id == get_goal_id():
		if data_value != null:
			data[data_key] = data_value
		else:
			data.erase(data_key)
	on_goal_data(data_key, data_value)

func on_goal_progress(progress_info):
	pass

func on_goal_data(data_key, data_value):
	pass

func _on_goal_progress(goal_id, progress_info):
	if goal_id == get_goal_id():
		on_goal_progress(progress_info)

func get_action_panel_scene_path()->String:
	return "res://items/GoalItemActions.tscn"

func get_goal_id()->String:
	push_error("Unspecified goal ID, must be set by the goal subclass")
	return "unknown"

func get_important_item(item_key) -> GameItem:
	for item_id in important_items:
		if important_items[item_id] == item_key:
			return IdManager.get_item_by_id(item_id)
	return null

func register_important_item(goal_id, item_key, item_id):
	if goal_id == get_goal_id():
		if item_key == null:
			deregister_important_item(item_id)
		else:
			important_items[item_id] = item_key
			Events.safe_connect('add_game_item', wait_for_important_item_create)
			Events.safe_connect('deleting_game_item', wait_for_important_item_delete)

func deregister_important_item(item_id):
	important_items.erase(item_id)
	if important_items.is_empty():
		Events.disconnect('add_game_item', wait_for_important_item_create)
		Events.disconnect('deleting_game_item', wait_for_important_item_delete)

func wait_for_important_item_create(game_item, parent_item, select_item=false):
	if important_items.has(game_item.get_id()):
		on_important_item_create(important_items[game_item.get_id()], game_item)

func wait_for_important_item_delete(game_item):
	if important_items.has(game_item.get_id()):
		on_important_item_delete(important_items[game_item.get_id()], game_item)
		deregister_important_item(game_item.get_id())

func on_important_item_create(item_key, game_item):
	pass
	
func on_important_item_delete(item_key, game_item):
	pass

func can_rename()->bool:
	return false
