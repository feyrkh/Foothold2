extends GameItem
class_name AreaItem

var explore_difficulty = 30 # seconds it takes to perform one explore action
var explore_progress = 0

const SELF_TAGS = {Tags.TAG_AREA:true}
const ALLOWED_TAGS = {Tags.TAG_LOCATION:true, Tags.TAG_PC:true, Tags.TAG_EQUIPMENT:true, Tags.TAG_FURNITURE:true}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS

func get_action_panel_scene_path()->String:
	return "res://items/FlexibleItemActions.tscn"

const ACTION_SECTIONS = ['Description', 'Explore']
func get_action_sections()->Array:
	return ACTION_SECTIONS
	
func get_description():
	pass

func has_more_explore_locations():
	return false # override in subclasses

func get_next_explore_location():
	return null
