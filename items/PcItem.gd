extends WorkAwareItem
class_name PcItem

func _init(label):
	super._init(label)
	inherent_work_types = {WorkTypes.EXPLORE: 1.0, 'prestidigitation': 2.5, 'b': 20, 'c': 3, 'd': 4, 'f': 5, 'g': 6, 'h': 6, 'w': 6, 'q': 6, 'z': 6, 'x': 6, }

func get_action_panel_scene_path()->String:
	return "res://items/PcItemActions.tscn"

const SELF_TAGS = {Tags.TAG_PC:true}
const ALLOWED_TAGS = {Tags.TAG_EQUIPMENT:true}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS

func get_work_amount(work_type:String) -> WorkAmount:
	var helpers_in_inventory = find_child_items(_is_work_helper)
	return super.get_work_amount_from_helpers(work_type, helpers_in_inventory)

func _is_work_helper(game_item) -> bool:
	return game_item.has_method('get_work_amount')

func get_description():
	return "A cool guy."

