extends WorkPartyItem
class_name WorkHeldItem

var worker_id

func _ready():
	super._ready()
	connect('parent_updated', moved_parents)

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

func moved_parents(old_parent, new_parent):
	var holder = get_closest_nonfolder_parent()
	var holder_id = holder.get_id()
	if worker_id != holder_id:
		worker_id = holder_id
		update_work_amounts()

func game_tick():
	if worker_id == null:
		Events.disconnect('game_tick', game_tick)
		return
	super.game_tick()

# Look for PCs 
func update_work_amounts():
	var holder = IdManager.get_item_by_id(worker_id)
	if holder == null:
		moved_parents(null, null)
		holder = IdManager.get_item_by_id(worker_id)
	var workers:Array[GameItem]
	if _is_worker(holder):
		workers = [holder]
	else:
		workers = []
	super.update_work_amounts_from_worker_list(workers)
