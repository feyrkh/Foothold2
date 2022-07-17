extends GameItem
class_name PcItem

func get_action_panel_scene_path()->String:
	return "res://items/PcItemActions.tscn"

const SELF_TAGS = {Tags.TAG_PC:true}
const ALLOWED_TAGS = {Tags.TAG_EQUIPMENT:true}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS

func get_work_amount(work_type:String) -> float:
	return 1.0
