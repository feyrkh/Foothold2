extends WorkPartyItem
class_name WorkHeldItem

# Called when creating object from WorkResult
func finish_resolve_item_result(args):
	pass # delete if not needed

func get_action_panel_scene_path()->String:
	return "res://items/WorkPartyItemActions.tscn"

const SELF_TAGS2 = {Tags.TAG_EQUIPMENT:true}
const ALLOWED_TAGS2 = {}
func get_tags()->Dictionary:
	return SELF_TAGS2

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS2

# Look for PCs 
func update_work_amounts():
	var holder = get_closest_nonfolder_parent()
	var workers:Array[GameItem]
	if _is_worker(holder):
		workers = [holder]
	else:
		workers = []
	super.update_work_amounts_from_worker_list(workers)
