extends GameItem
class_name WorkPartyItem

const WORK_TARGET_ALL_SIMULTANEOUS = 1 << 0
const WORK_TARGET_ALL_SERIAL = 1 << 1
const WORK_TARGET_PARENT_ONLY = 1 << 2
const WORK_TARGET_SPECIFIC_ITEM = 1 << 3

var work_types:Dictionary = {}
var max_workers:int = 1
var valid_work_target_types:int = WORK_TARGET_ALL_SERIAL | WORK_TARGET_ALL_SIMULTANEOUS | WORK_TARGET_PARENT_ONLY | WORK_TARGET_SPECIFIC_ITEM
var work_target_type:int = WORK_TARGET_ALL_SERIAL
var work_specific_target_id:int

func get_action_panel_scene_path()->String:
	return "res://items/WorkPartyItemActions.tscn"

func _ready():
	super._ready()
	Events.connect('game_tick', game_tick)
	connect('contents_updated', update_work_amount)

func set_work_types(type_names:Array[String]):
	work_types = {}
	for type_name in type_names:
		work_types[type_name] = 0
	update_work_amount()

func get_work_types() -> Dictionary:
	return work_types
	
func game_tick():
	pass

# Look for PCs 
func update_work_amount():
	var workers:Array[GameItem] = super.find_child_items(_is_worker)
	for work_type in work_types:
		var amt = 0
		for worker in workers:
			amt += worker.get_work_amount(work_type)
		work_types[work_type] = amt

func _is_worker(game_item:GameItem) -> bool:
	return game_item.has_method('get_work_amount')

const SELF_TAGS = {Tags.TAG_WORK:true}
const ALLOWED_TAGS = {Tags.TAG_PC:true}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS

