extends GameItem
class_name LocationItem

# map of GameItem.get_id() -> Vector2 positions on the game grid
var furniture_locations = {}
var size:Vector2 = Vector2(5, 5)

func get_action_panel_scene_path()->String:
	return "res://items/LocationItemActions.tscn"


const SELF_TAGS = {Tags.TAG_LOCATION:true}
const ALLOWED_TAGS = {Tags.TAG_PC:true, Tags.TAG_EQUIPMENT:true, Tags.TAG_FURNITURE:true}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS
