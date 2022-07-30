extends WorkAwareItem
class_name PcItem

func _init():
	super._init()
	inherent_work_amounts = {
		WorkTypes.EXPLORE: WorkAmount.new(WorkTypes.EXPLORE, 1.0, 0, []),
		WorkTypes.MANUAL_LABOR: WorkAmount.new(WorkTypes.MANUAL_LABOR, 1.0, 0, []),
	}

func get_action_panel_scene_path()->String:
	return "res://items/PcItemActions.tscn"

const SELF_TAGS = {Tags.TAG_PC:true}
const ALLOWED_TAGS = {Tags.TAG_EQUIPMENT:true}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS
	
func get_description():
	return "A cool guy."

