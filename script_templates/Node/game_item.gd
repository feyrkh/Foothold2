extends GameItem

# Called when creating object from WorkResult
func finish_resolve_item_result(args):
	pass # delete if not needed

func get_action_panel_scene_path()->String:
	return "res://items/FlexibleItemActions.tscn"

const ACTION_SECTIONS = ['Description']
func get_action_sections()->Array:
	return ACTION_SECTIONS

const SELF_TAGS = {}
const ALLOWED_TAGS = {}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS
	
func get_description():
	return "A cool guy."
