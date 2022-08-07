extends GameItem
class_name Goal

var completed = null:
	set(val):
		completed = val
		if completed:
			var complete_section = find_child('GoalCompleteSection', true, false)
			if complete_section:
				complete_section.refresh()
var data = {}
var important_items_by_game_id = {} # game_item.get_id() -> key
var important_items_by_item_key = {} # key -> game_item.get_id()

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
	return "res://items/FlexibleItemActions.tscn"

const ACTION_SECTIONS = ['DescriptionWide', 'GoalComplete']
func get_action_sections()->Array:
	return ACTION_SECTIONS

func get_goal_id()->String:
	push_error("Unspecified goal ID, must be set by the goal subclass")
	return "unknown"

func get_important_item(item_key) -> GameItem:
	return IdManager.get_item_by_id(important_items_by_item_key.get(item_key))

func register_important_item(goal_id, item_key, item_id):
	if goal_id == get_goal_id():
		if item_key == null:
			deregister_important_item(item_id)
		else:
			important_items_by_game_id[item_id] = item_key
			important_items_by_item_key[item_key] = item_id
			Events.safe_connect('add_game_item', wait_for_important_item_create)
			Events.safe_connect('deleting_game_item', wait_for_important_item_delete)

func deregister_important_item(item_id):
	var item_key = important_items_by_game_id.get(item_id)
	if item_key:
		important_items_by_item_key.erase(item_key)
	important_items_by_game_id.erase(item_id)
	if important_items_by_game_id.is_empty():
		Events.disconnect('add_game_item', wait_for_important_item_create)
		Events.disconnect('deleting_game_item', wait_for_important_item_delete)

func wait_for_important_item_create(game_item, parent_item, select_item=false):
	if important_items_by_game_id.has(game_item.get_id()):
		on_important_item_create(important_items_by_game_id[game_item.get_id()], game_item)

func wait_for_important_item_delete(game_item):
	if important_items_by_game_id.has(game_item.get_id()):
		on_important_item_delete(important_items_by_game_id[game_item.get_id()], game_item)
		deregister_important_item(game_item.get_id())

func on_important_item_create(item_key, game_item):
	pass
	
func on_important_item_delete(item_key, game_item):
	pass

func can_rename()->bool:
	return false
