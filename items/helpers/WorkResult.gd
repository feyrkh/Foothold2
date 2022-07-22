extends RefCounted
class_name WorkResult

const KEY_RESULT_TYPE = 't'
const KEY_ITEM_NAME = 'n'
const KEY_ITEM_SCRIPT = 's'
const KEY_OWNER_ID = 'o'
const KEY_SETUP_ARGS = 'a'

const ITEM_RESULT = 1


var pre_complete_desc = "Working..."
var post_complete_desc = "Work complete!"
var results = []

func new_item_result(item_name:String, item_script:String, target_owner_id, setup_args=null):
	results.append({KEY_RESULT_TYPE: ITEM_RESULT, KEY_ITEM_NAME: item_name, KEY_ITEM_SCRIPT: item_script, KEY_OWNER_ID: target_owner_id, KEY_SETUP_ARGS: setup_args})

func resolve_results():
	for result in results:
		match result.get('t'):
			ITEM_RESULT: resolve_item_result(result)
			_: push_error("Tried to resolve unexpected result type: ", result)

static func resolve_item_result(result:Dictionary):
	var item = load(result[KEY_ITEM_SCRIPT]).instantiate()
	item.setup_result(result['a'])
	Factory.place_item(item, IdManager.get_item_by_id(result['o']))
	
