extends GameItem
class_name LocationItem

func get_action_panel_scene_path()->String:
	return "res://items/FlexibleItemActions.tscn"

const ACTION_SECTIONS = ['Description']
func get_action_sections()->Array:
	return ACTION_SECTIONS

const SELF_TAGS = {Tags.TAG_LOCATION:true}
const ALLOWED_TAGS = {Tags.TAG_PC:true, Tags.TAG_EQUIPMENT:true, Tags.TAG_FURNITURE:true}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS
