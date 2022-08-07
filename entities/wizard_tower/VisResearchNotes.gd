extends GameItem

func get_action_panel_scene_path()->String:
	return "res://items/FlexibleItemActions.tscn"

const ACTION_SECTIONS = ['DescriptionWide']
func get_action_sections()->Array:
	return ACTION_SECTIONS

const SELF_TAGS = {Tags.TAG_EQUIPMENT:true}
const ALLOWED_TAGS = {}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS
	
func get_description():
	return "A collection of notes written by researchers back home, regarding the energy tentatively being called 'vis'. Highlights:\n" + \
		"  - Crystalline structures such as gemstones can be used to store vis\n" + \
		"  - Size determines the quantity of vis a given stone may store\n" + \
		"  - Crystal structure determines the speed at which vis can be absorbed/released by a stone\n" + \
		"  - Vis seems to react to human thoughts and actions, research is ongoing\n" + \
		"  - The new world through the portal is far richer in vis than home\n" + \
		"  - The vis imbalance makes it easy for things to travel back home through the portal, but objects and people going from home to the new world cause portal instability\n" + \
		"  - Applying vis to the portal increases stability, allowing supplies to pass through\n" + \
		"  - Vis gems attempt to equalize vis with the portal, so higher stability will require gems with higher capacity, not just more tiny gems"

