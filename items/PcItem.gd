extends WorkAwareItem
class_name PcItem

# How much concentration regenerates per second, as well as how much can be applied per second
var focus := 1.0

var concentration := 1.0:
	set(val):
		var prev_concentration = inherent_work_amounts.get(WorkTypes.CONCENTRATION, 0)
		var new_concentration = max(0, min(concentration, focus))
		if prev_concentration != new_concentration:
			inherent_work_amounts[WorkTypes.CONCENTRATION] = new_concentration
			update_specific_work_amount(WorkTypes.CONCENTRATION)

func _init():
	super._init()
	inherent_work_amounts = {
		WorkTypes.EXPLORE: WorkAmount.new(WorkTypes.EXPLORE, 1.0, 0, {}),
		WorkTypes.MANUAL_LABOR: WorkAmount.new(WorkTypes.MANUAL_LABOR, 1.0, 0, {}),
	}

func get_action_panel_scene_path()->String:
	return "res://items/FlexibleItemActions.tscn"

const ACTION_SECTIONS = ['Description', 'WorkProvided']
func get_action_sections()->Array:
	return ACTION_SECTIONS

const SELF_TAGS = {Tags.TAG_PC:true}
const ALLOWED_TAGS = {Tags.TAG_EQUIPMENT:true}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS
	
func get_description():
	return "A cool guy."

func get_furniture_size():
	return 1
