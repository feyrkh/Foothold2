extends RefCounted
class_name WorkResult

const KEY_SETUP_ARGS = 'a' # passed to `finish_resolve_item_result` on the new item, if it has that function
const KEY_GOAL_ID = 'g'
const KEY_GOAL_DATA_KEY = 'k'
const KEY_ITEM_NAME = 'n'
const KEY_OWNER_ID = 'o'
const KEY_GOAL_PROGRESS = 'p'
const KEY_ITEM_SCRIPT = 's'
const KEY_RESULT_TYPE = 't'
const KEY_GOAL_PROGRESS_VAL = 'v'
const KEY_GOAL_DATA_VAL = 'V'

const ITEM_RESULT = 1
const GOAL_PROGRESS_RESULT = 2
const GOAL_DATA_RESULT = 3

var pre_complete_desc = "Working..."
var post_complete_desc = "Work complete!"
var results = []

func new_item_result(item_name:String, item_script:String, target_owner_id, setup_args=null):
	results.append({KEY_RESULT_TYPE: ITEM_RESULT, KEY_ITEM_NAME: item_name, KEY_ITEM_SCRIPT: item_script, KEY_OWNER_ID: target_owner_id, KEY_SETUP_ARGS: setup_args})

func goal_progress(goal_id, progress_val):
	results.append({KEY_RESULT_TYPE: GOAL_PROGRESS_RESULT, KEY_GOAL_PROGRESS_VAL: progress_val, KEY_GOAL_ID: goal_id})

func goal_data(goal_id, data_key, data_val):
	results.append({KEY_RESULT_TYPE: GOAL_DATA_RESULT, KEY_GOAL_ID: goal_id, KEY_GOAL_DATA_KEY: data_key, KEY_GOAL_DATA_VAL: data_val})

func resolve_results():
	for result in results:
		match result.get('t'):
			ITEM_RESULT: resolve_item_result(result)
			GOAL_PROGRESS_RESULT: Events.emit_signal('goal_progress', result[KEY_GOAL_ID], result[KEY_GOAL_PROGRESS_VAL])
			GOAL_DATA_RESULT: Events.emit_signal('goal_data', result[KEY_GOAL_ID], result[KEY_GOAL_DATA_KEY], result[KEY_GOAL_DATA_VAL])
			_: push_error("Tried to resolve unexpected result type: ", result)

static func resolve_item_result(result:Dictionary):
	var item:GameItem = load(result[KEY_ITEM_SCRIPT]).new()
	item.init(result.get(KEY_ITEM_NAME, 'Unknown item'))
	var setup_args = result.get(KEY_SETUP_ARGS)
	if setup_args is Dictionary and setup_args.has('_item_id'):
		item._item_id = setup_args['_item_id']
	if item.has_method('finish_resolve_item_result'):
		item.finish_resolve_item_result(result.get(KEY_SETUP_ARGS))
	Events.emit_signal('add_game_item', item, IdManager.get_item_by_id(result['o']))
	
