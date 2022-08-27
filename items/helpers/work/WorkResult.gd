extends RefCounted
class_name WorkResult

const KEY_SETUP_ARGS = 'a' # passed to `finish_resolve_item_result` on the new item, if it has that function
const KEY_BUFF = 'b'
const KEY_BUFF_ID = 'buff_id' # has to match with the Buff.buff_id field
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
const ON_RESOLVE_CALLBACK_RESULT = 4 # callback for when user clicks the 'complete' button to clear out the completed task
const DESTROY_RESULT = 5
const BUFF_ON_COMPLETE_RESULT = 6
const BUFF_WHILE_WORKING_RESULT = 7
const ON_CREATE_CALLBACK_RESULT = 8 # callback for when the task is first created
const ON_COMPLETE_CALLBACK_RESULT = 9 # callback for when the work is completed, but not yet resolved

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

func new_item_result(item_name:String, item_script:String, target_game_item_or_id, setup_args=null):
	results.append({KEY_RESULT_TYPE: ITEM_RESULT, KEY_ITEM_NAME: item_name, KEY_ITEM_SCRIPT: item_script, KEY_OWNER_ID: target_to_id(target_game_item_or_id), KEY_SETUP_ARGS: setup_args})

func new_location_result(location_name:String, target_owner_id, room_size=1, setup_args={}, item_script="res://items/LocationItem.gd"):
	setup_args[LocationItem.KEY_ROOM_SIZE] = room_size
	results.append({KEY_RESULT_TYPE: ITEM_RESULT, KEY_ITEM_NAME: location_name, KEY_ITEM_SCRIPT: item_script, KEY_OWNER_ID: target_owner_id, KEY_SETUP_ARGS: setup_args})

func destroy_item_result(item_id, destroy_children:bool):
	results.append({KEY_RESULT_TYPE: DESTROY_RESULT, KEY_GAME_ITEM_ID: item_id, KEY_FUNCTION_ARGS: destroy_children})

func goal_progress(goal_id, progress_val):
	results.append({KEY_RESULT_TYPE: GOAL_PROGRESS_RESULT, KEY_GOAL_PROGRESS_VAL: progress_val, KEY_GOAL_ID: goal_id})

func goal_data(goal_id, data_key, data_val):
	results.append({KEY_RESULT_TYPE: GOAL_DATA_RESULT, KEY_GOAL_ID: goal_id, KEY_GOAL_DATA_KEY: data_key, KEY_GOAL_DATA_VAL: data_val})

func on_resolve_callback_result(target_game_item_or_id, function_name, args=[]):
	results.append({KEY_RESULT_TYPE: ON_RESOLVE_CALLBACK_RESULT, KEY_GAME_ITEM_ID: target_to_id(target_game_item_or_id), KEY_FUNCTION_NAME: function_name, KEY_FUNCTION_ARGS: args})

func on_create_callback_result(target_game_item_or_id, function_name, args=[]):
	results.append({KEY_RESULT_TYPE: ON_CREATE_CALLBACK_RESULT, KEY_GAME_ITEM_ID: target_to_id(target_game_item_or_id), KEY_FUNCTION_NAME: function_name, KEY_FUNCTION_ARGS: args})

func on_complete_callback_result(target_game_item_or_id, function_name, args=[]):
	results.append({KEY_RESULT_TYPE: ON_COMPLETE_CALLBACK_RESULT, KEY_GAME_ITEM_ID: target_to_id(target_game_item_or_id), KEY_FUNCTION_NAME: function_name, KEY_FUNCTION_ARGS: args})

func buff_on_complete_result(target_game_item_or_id, buff:Buff):
	results.append({KEY_RESULT_TYPE: BUFF_ON_COMPLETE_RESULT, KEY_GAME_ITEM_ID: target_to_id(target_game_item_or_id), KEY_BUFF: Config.to_config(buff)})

func buff_while_working_result(buff:Buff):
	var buff_config = Config.to_config(buff)
	buff_config.buff_id = randi()
	results.append({KEY_RESULT_TYPE: BUFF_WHILE_WORKING_RESULT, KEY_BUFF: buff_config})

func target_to_id(target_game_item_or_id):
	var id = target_game_item_or_id
	if id is GameItem:
		id = id.get_id()
	return id

func resolve_work_created_results():
	for result in results:
		match result.get(KEY_RESULT_TYPE):
			ON_CREATE_CALLBACK_RESULT: resolve_callback_result(result)

# called when a new worker is added to a task
func resolve_work_start_results(worker_id):
	for result in results:
		match result.get(KEY_RESULT_TYPE):
			BUFF_WHILE_WORKING_RESULT: add_working_buff(result.get(KEY_BUFF), worker_id)

# called when a worker is removed from a task, either because they stopped working, paused working, or the task completed
func resolve_work_stop_results(worker_id):
	for result in results:
		match result.get(KEY_RESULT_TYPE):
			BUFF_WHILE_WORKING_RESULT: remove_working_buff(result.get(KEY_BUFF), worker_id)

func resolve_work_completed_results():
	for result in results:
		match result.get(KEY_RESULT_TYPE):
			ON_COMPLETE_CALLBACK_RESULT: resolve_callback_result(result)

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
			ON_RESOLVE_CALLBACK_RESULT: resolve_callback_result(result)
			ON_CREATE_CALLBACK_RESULT: pass # handled on creation
			ON_COMPLETE_CALLBACK_RESULT: pass # handled on completion
			BUFF_ON_COMPLETE_RESULT:
				var game_item = IdManager.get_item_by_id(result.get(KEY_GAME_ITEM_ID))
				if game_item == null:
					push_error('Tried to add buff to nonexistent GameItem: ', result)
					return
				if !game_item.has_method('add_buff'):
					push_error('Tried to add buff to GameItem with no add_buff(): ', result)
					return
				var buff_config = result.get(KEY_BUFF)
				var buff = Buff.new()
				Config.config(buff, buff_config)
				game_item.add_buff(buff)
			BUFF_WHILE_WORKING_RESULT:
				pass
			_: push_error("Tried to resolve unexpected result type: ", result)

func resolve_callback_result(result):
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

func add_working_buff(buff_config:Dictionary, target_id):
	var game_item = IdManager.get_item_by_id(target_id)
	if game_item == null:
		push_error('Tried to add working buff on nonexistent GameItem (', target_id, '): : ', buff_config)
		return
	if !game_item.has_method('add_buff'):
		push_error('Tried to add working buff on GameItem (', target_id, '):  with no add_buff(): ', buff_config)
		return
	var buff = Buff.new()
	Config.config(buff, buff_config)
	game_item.add_buff(buff)

func remove_working_buff(buff_config:Dictionary, target_id):
	var game_item = IdManager.get_item_by_id(target_id)
	if game_item == null:
		push_error('Tried to remove working buff on nonexistent GameItem (', target_id, '): ', buff_config)
		return
	if !game_item.has_method('remove_buff_by_id'):
		push_error('Tried to remove working buff on GameItem (', target_id, '):  with no remove_buff_by_id(): ', buff_config)
		return
	game_item.remove_buff_by_id(buff_config.get(KEY_BUFF_ID))
	
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
	
