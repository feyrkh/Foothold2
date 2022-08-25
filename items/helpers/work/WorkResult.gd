extends RefCounted
class_name WorkResult

const KEY_SETUP_ARGS = 'a' # passed to `finish_resolve_item_result` on the new item, if it has that function
const KEY_FUNCTION_NAME = 'F'
const KEY_FUNCTION_ARGS = 'f'
const KEY_GOAL_ID = 'g' # Used with GOAL_PROGRESS_RESULT and GOAL_DATA_RESULT, the ID of the goal to be updated
const KEY_GAME_ITEM_ID = 'i'
const KEY_GOAL_DATA_KEY = 'k' # Used with GOAL_DATA_RESULT, the key of the data to update
const KEY_ITEM_NAME = 'n' # Used with KEY_ITEM_RESULT, the item's label will be set to this
const KEY_OWNER_ID = 'o' # Used with KEY_ITEM_RESULT, the item will be created under this ID
const KEY_LOCK_TO_OWNER = 'OL' # Used with KEY_ITEM_RESULT, set truthy to set the item's lock value to the owner it is assigned to
const KEY_ITEM_SCRIPT = 's' # Used with KEY_ITEM_RESULT, path to the script to use for the new item
const KEY_RESULT_TYPE = 't' # Set to one of the *_RESULT consts below
const KEY_GOAL_PROGRESS_VAL = 'v' # Used with GOAL_PROGRESS_RESULT, the new progress value for the goal
const KEY_GOAL_DATA_VAL = 'V' # Used with GOAL_DATA_RESULT, the new value for the goal data

const ITEM_RESULT = 1
const GOAL_PROGRESS_RESULT = 2
const GOAL_DATA_RESULT = 3
const CALLBACK_RESULT = 4
const DESTROY_RESULT = 5

var pre_complete_desc = "Working..."
var post_complete_desc = "Work complete!"
var results = []

static func build_from_config(config) -> WorkResult:
	if config == null:
		return null
	var work_result = WorkResult.new()
	Config.config(work_result, config)
	return work_result

func _from_config(config) -> WorkResult:
	if config == null:
		return null
	Config.config(self, config)
	return self

func new_item_result(item_name:String, item_script:String, target_owner_id, setup_args=null):
	if target_owner_id is TreeNode:
		target_owner_id = target_owner_id.get_id()
	results.append({KEY_RESULT_TYPE: ITEM_RESULT, KEY_ITEM_NAME: item_name, KEY_ITEM_SCRIPT: item_script, KEY_OWNER_ID: target_owner_id, KEY_SETUP_ARGS: setup_args})

func new_location_result(location_name:String, target_owner_id, room_size=1, setup_args={}, item_script="res://items/LocationItem.gd"):
	setup_args[LocationItem.KEY_ROOM_SIZE] = room_size
	results.append({KEY_RESULT_TYPE: ITEM_RESULT, KEY_ITEM_NAME: location_name, KEY_ITEM_SCRIPT: item_script, KEY_OWNER_ID: target_owner_id, KEY_SETUP_ARGS: setup_args})

func destroy_item_result(item_id, destroy_children:bool):
	results.append({KEY_RESULT_TYPE: DESTROY_RESULT, KEY_GAME_ITEM_ID: item_id, KEY_FUNCTION_ARGS: destroy_children})

func goal_progress(goal_id, progress_val):
	results.append({KEY_RESULT_TYPE: GOAL_PROGRESS_RESULT, KEY_GOAL_PROGRESS_VAL: progress_val, KEY_GOAL_ID: goal_id})

func goal_data(goal_id, data_key, data_val):
	results.append({KEY_RESULT_TYPE: GOAL_DATA_RESULT, KEY_GOAL_ID: goal_id, KEY_GOAL_DATA_KEY: data_key, KEY_GOAL_DATA_VAL: data_val})

func callback_result(target_game_item_or_id, function_name, args=[]):
	var id = target_game_item_or_id
	if id is GameItem:
		id = id.get_id()
	results.append({KEY_RESULT_TYPE: CALLBACK_RESULT, KEY_GAME_ITEM_ID: id, KEY_FUNCTION_NAME: function_name, KEY_FUNCTION_ARGS: args})

func resolve_results():
	for result in results:
		match result.get('t'):
			ITEM_RESULT: resolve_item_result(result)
			GOAL_PROGRESS_RESULT: Events.emit_signal('goal_progress', result[KEY_GOAL_ID], result[KEY_GOAL_PROGRESS_VAL])
			GOAL_DATA_RESULT: Events.emit_signal('goal_data', result[KEY_GOAL_ID], result[KEY_GOAL_DATA_KEY], result[KEY_GOAL_DATA_VAL])
			DESTROY_RESULT: 
				var game_item:GameItem = IdManager.get_item_by_id(result.get(KEY_GAME_ITEM_ID))
				var delete_children = result.get(KEY_FUNCTION_ARGS)
				if game_item == null:
					push_error('Tried to destroy nonexistent GameItem: ', result)
					return
				game_item.delete(delete_children)
			CALLBACK_RESULT: 
				var game_item = IdManager.get_item_by_id(result.get(KEY_GAME_ITEM_ID))
				if game_item == null:
					push_error('Tried to run callback function in nonexistent GameItem: ', result)
					return
				if !game_item.has_method(result.get(KEY_FUNCTION_NAME)):
					push_error('Tried to run nonexistent callback function: ', result)
					return
				var args = result.get(KEY_FUNCTION_ARGS, [])
				if args == null: args = []
				game_item.callv(result.get(KEY_FUNCTION_NAME), args)
			_: push_error("Tried to resolve unexpected result type: ", result)

func get_result_description() -> String:
	if results == null or results.size() == 0:
		return 'none'
	var msg = PackedStringArray()
	for result in results:
		match result.get('t'):
			ITEM_RESULT: msg.append(result.get(KEY_ITEM_NAME))
	return ', '.join(msg)

static func resolve_item_result(result:Dictionary):
	var item:GameItem
	if !Directory.new().file_exists(result[KEY_ITEM_SCRIPT]):
		item = load("res://items/ErroredItem.gd").new()
		item.set_error_data(result)
	else:
		item = load(result[KEY_ITEM_SCRIPT]).new()
	item.init(result.get(KEY_ITEM_NAME, 'Unknown item'))
	var setup_args = result.get(KEY_SETUP_ARGS)
	if setup_args is Dictionary and setup_args.has('_item_id'):
		item._item_id = setup_args['_item_id']
	if item.has_method('finish_resolve_item_result'):
		item.finish_resolve_item_result(result.get(KEY_SETUP_ARGS))
	if result.get(KEY_LOCK_TO_OWNER, false):
		item.allowed_owner_lock_id = result[KEY_OWNER_ID]
	Events.emit_signal('add_game_item', item, IdManager.get_item_by_id(result[KEY_OWNER_ID]), true)
	
