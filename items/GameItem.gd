extends TreeNode
class_name GameItem

# Possible callbacks:
# finish_resolve_item_result(args): Called from WorkResult when some work is completed and this item has been created as a result.
#		Used to configure a new item based on the args that are passed.

var _item_id:int
var action_panel
var callbacks = null

func get_ignore_field_names() -> Dictionary:
	return {'action_panel':true, 'tree_item':true}

func _ready():
	super._ready()
	Events.connect('pre_load_game', pre_load_game)
	
func pre_load_game():
	queue_free() # gotta wipe the old game state before loading a new one

func get_default_label():
	return 'Unknown item'

func get_id()->int:
	if _item_id == 0 or _item_id == null:
		_item_id = IdManager.get_next_id(self)
	return _item_id

func set_callback(callback_id:String, callback_owner_item_id:int, callback_function_name:String):
	if callbacks == null:
		callbacks = {}
	callbacks[callback_id] = [callback_owner_item_id, callback_function_name]

func execute_callback(callback_id:String):
	if callbacks == null:
		return
	var callback_data = callbacks.get(callback_id)
	if callback_data == null or !(callback_data is Array) or callback_data.size() < 2:
		return
	var owner_item = IdManager.get_item_by_id(callback_data[0])
	if owner_item != null and owner_item.has_method(callback_data[1]):
		owner_item.call(callback_data[1], self)

func can_rename()->bool:
	return true

func can_delete()->bool:
	return false

func can_create_subfolder():
	return !(get_allowed_tags().is_empty())

func get_action_panel():
	if action_panel and is_instance_valid(action_panel):
		return action_panel
	else:
		action_panel = null
		return null

func refresh_action_panel():
	if action_panel and is_instance_valid(action_panel) and action_panel.has_method('refresh_action_panel'):
		action_panel.call_deferred('refresh_action_panel')

func build_action_panel(game_ui):
	var existing_panel = get_action_panel()
	if existing_panel:
		return existing_panel
	var path = get_action_panel_scene_path()
	if path == null:
		path = "res://items/GameItemActions.tscn"
	var packed_scene
	var panel
	if !ResourceLoader.exists(path, "PackedScene"):
		packed_scene = load("res://items/ErroredItemActions.tscn")
		panel = packed_scene.instantiate()
		panel.init_error(path)
	else:
		panel = load(path).instantiate()
	panel.setup_action_panel(game_ui, self)
	action_panel = panel
	return panel

func get_action_panel_scene_path()->String:
	return "res://items/GameItemActions.tscn"

func find_sibling_items(filter_func:Callable, deep=false)->Array:
	var parent_item = get_closest_nonfolder_parent()
	if !parent_item:
		return []
	return parent_item.find_child_items(filter_func, false)

func find_child_items(filter_func:Callable, deep=false):
	var results:Array[GameItem] = []
	if !tree_item or !tree_item.get_child_count():
		return results
	var tree_items = tree_item.get_children()
	for tree_item in tree_items:
		var game_item = tree_item.get_metadata(0)
		if game_item == null or !is_instance_valid(game_item):
			#push_error('game_item unexpectedly null in tree_item with text(0)=', tree_item.get_text(0))
			# can be null when there's a placeholder for dropping items
			continue
		if filter_func.call(game_item):
			results.append(game_item)
		if deep or game_item.get_tags().has(Tags.TAG_FOLDER):
			results.append_array(game_item.find_child_items(filter_func, deep))
	return results

func on_delete_tree_node():
	Events.emit_signal('deleting_game_item', self)
