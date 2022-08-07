extends GameItem
class_name GemItem

signal vis_updated(gem_item)

const size_desc:Dictionary = {
	1: 'shard of',
	2: 'pebble of',
	3: 'tiny',
	4: 'small',
	5: 'fingernail-sized',
	6: 'marble-sized',
	7: 'large',
	8: 'fist-sized',
	9: 'head-sized',
	10: 'massive',
	11: 'head-sized',
	12: 'boulder-sized',
	13: 'monumental',
}

const IDX_GEM_NAME = 0
const IDX_MAX_VIS_MULTIPLIER = 1
const IDX_VIS_INPUT_SPEED = 2
const IDX_VIS_OUTPUT_SPEED = 3

const RESOLVE_KEY_GEM_SIZE = 'gs'
const RESOLVE_KEY_GEM_TYPE_ID = 'gt'
const RESOLVE_KEY_GEM_VIS_AMT = 'gva'
const RESOLVE_KEY_GEM_VIS_TYPE = 'gvt'

const gem_type_desc = [
	# Array of stats for each gem
	# 0: gem name
	# 1: max vis multiplier
	# 2: input speed (vis/sec)
	# 3: output speed (vis/sec)
	['quartz', 0.1, 0.1, 0.1],
	['rutilated quartz', 0.3, 0.5, 0.1],
	['agate', 0.5, 0.2, 0.2],
	['hematite', 1, 0.3, 1],
	['lapis', 2, 1, 0.3],
	['obsidian', 5, 0.1, 0.1],
	['malachite', 10, 0.1, 0.1],
	['tiger eye', 15, 0.1, 0.1],
	['turquoise', 30, 0.1, 0.1],
	['citrine', 90, 0.1, 0.1],
	['jasper', 100, 0.1, 0.1], 
	['carnelian', 120, 0.1, 0.1],
	['moonstone', 300, 0.1, 0.1],
	['onyx', 400, 0.1, 0.1],
	['rose quartz', 500, 0.1, 0.1],
	['amber', 600, 0.1, 0.1],
	['amethyst', 600, 0.1, 0.1],
	['chysoberyl', 600, 0.1, 0.1],
	['garnet', 600, 0.1, 0.1],
	['jade', 1000, 0.1, 0.1],
	['jet', 100, 20, 20],
	['spinel', 2000, 0.1, 0.1],
	['tourmaline', 3000, 0.1, 0.1],
	['aquamarine', 4000, 0.1, 0.1],
	['peridot', 5000, 0.1, 0.1],
	['topaz', 10000, 0.1, 0.1],
	['sapphire', 15000, 0.1, 0.1],
	['emerald', 30000, 0.1, 0.1],
	['fire opal', 20000, 5, 80],
	['opal', 35000, 0.1, 0.1],
	['ruby', 50000, 0.1, 0.1],
	['diamond', 100000, 0.1, 0.1],
	['star sapphire', 15000, 0.1, 0.1],
	['star emerald', 30000, 0.1, 0.1],
	['star ruby', 50000, 0.1, 0.1],
]

var size:int = 0 :
	set(val):
		size = min(max(val, 1), size_desc.size())

var gem_type:int = 0 :
	set(val):
		if gem_type < 0: 
			gem_type = 0
		elif gem_type >= gem_type_desc.size(): 
			gem_type = gem_type_desc.size()-1
		
var vis:float = 0:
	set(val):
		if val != vis:
			vis = min(val, get_max_vis())
			vis_updated.emit(self)

var vis_type:int = Vis.TYPE_IMPURE
var vis_target
var last_sent_vis = 0:
	set(val):
		if last_sent_vis != val:
			vis_updated.emit(self)

var cached_max_vis

func get_ignore_field_names() -> Dictionary:
	var result = {'vis_target':true, 'cached_max_vis':true}
	result.merge(super.get_ignore_field_names())
	return result

func _ready():
	super._ready()

static func get_resolve_item_args(gem_size:int, gem_type:int, vis_amt:float, vis_type:int) -> Dictionary:
	var result = {}
	if gem_size != 0:
		result[RESOLVE_KEY_GEM_SIZE] = gem_size
	if gem_type != 0:
		result[RESOLVE_KEY_GEM_TYPE_ID] = gem_type
	if vis_amt != 0:
		result[RESOLVE_KEY_GEM_VIS_AMT] = vis_amt
	if vis_type != Vis.TYPE_IMPURE:
		result[RESOLVE_KEY_GEM_VIS_TYPE] = vis_type
	return result

func finish_resolve_item_result(args:Dictionary):
	if args == null:
		push_error('Invalid args when resolving GemItem: ', args)
		return
	size = args.get(RESOLVE_KEY_GEM_SIZE, 0)
	gem_type = args.get(RESOLVE_KEY_GEM_TYPE_ID, 0)
	vis = args.get(RESOLVE_KEY_GEM_VIS_AMT, 0)
	vis_type = args.get(RESOLVE_KEY_GEM_VIS_TYPE, Vis.TYPE_IMPURE)
	set_label("%s of %s" % [get_size_desc(), get_gem_type_desc()])

func get_size_desc() -> String:
	return size_desc.get(size, 'pebble')

func get_gem_type_desc() -> String:
	return gem_type_desc[gem_type][IDX_GEM_NAME]

func get_max_vis() -> float:
	if !cached_max_vis:
		cached_max_vis = (size * size) * gem_type_desc[gem_type][IDX_MAX_VIS_MULTIPLIER]
	return cached_max_vis

func get_vis_input_speed() -> float:
	return gem_type_desc[gem_type][IDX_VIS_INPUT_SPEED]
	
func get_vis_output_speed() -> float:
	return gem_type_desc[gem_type][IDX_VIS_OUTPUT_SPEED]
	
func get_vis() -> float:
	return vis

func get_vis_type() -> int:
	return vis_type

func get_luxury() -> float:
	return pow(2, int((size+1)/2.0)) * (0.5 * (size % 2)) 

func drain_vis(requested_amt:float) -> float:
	if requested_amt <= 0:
		return 0.0
	var provided_amt = min(requested_amt, get_vis())
	if provided_amt != 0: vis -= provided_amt
	return provided_amt

func get_vis_power_draw_desc():
	if last_sent_vis <= 0: return ""
	elif last_sent_vis <= 0.2: return "A glint of light sparks from within."
	elif last_sent_vis <= 0.4: return "Sparks of light flicker within the stone."
	elif last_sent_vis <= 1.0: return "Threads of power writhe over the stone."
	elif last_sent_vis <= 2.0: return "The stone glows with a steady light."
	elif last_sent_vis <= 3.0: return "Light blazes forth from the stone."
	elif last_sent_vis <= 5.0: return "The stone glows like a fragment of a star as it pours its power forth."
	else: return "Soul-searing light erupts from the stone like a fountain."

func get_description():
	return "A %s %s. %s" % [get_size_desc(), get_gem_type_desc(), get_vis_power_draw_desc()]

func get_action_panel_scene_path()->String:
	return "res://items/FlexibleItemActions.tscn"

const ACTION_SECTIONS = ['Description', 'VisContainer']
func get_action_sections()->Array:
	return ACTION_SECTIONS
	
const SELF_TAGS = {Tags.TAG_EQUIPMENT:true, Tags.TAG_FURNITURE:true, Tags.TAG_VIS_SUPPLIER:true}
const ALLOWED_TAGS = {}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS

