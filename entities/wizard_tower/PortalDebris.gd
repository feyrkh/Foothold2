extends WorkProvidingItem

const TASK_CLEAR_DEBRIS = 'clr' 

var clear_task = WorkTask.new()

# When all debris in the room is cleared, a portal will open

func get_furniture_size():
	return 3


func get_work_task_options(requestor:GameItem) -> Dictionary:
	var result = {TASK_CLEAR_DEBRIS: WorkTaskOption.build(TASK_CLEAR_DEBRIS, "Clear", get_id(), "Tidy up, make space in the room, and possibly uncover useful objects.", WorkTask.LOCATION_SHARED_ROOM)}
	return self.work_task_list.filter_task_options(result, requestor)

func build_work_task(next_task:WorkTaskOption, contributor:GameItem) -> WorkTask:
	match next_task.get_id():
		TASK_CLEAR_DEBRIS: return clear_task
		_: return null

func finish_resolve_item_result(args):
	#init_work_party("Scattered debris", Tags.WORK_PARTY_MANUAL_LABOR, {WorkTypes.MANUAL_LABOR: args.get('work', 0)})
	clear_task = WorkTask.new()
	clear_task.set_work_needed({WorkTypes.MANUAL_LABOR: args.get('work', 0)})
	var pre_desc = "Broken and crumbled masonry, splintered timbers, and other assorted refuse."
	var post_desc
	var has_prybar = args.get('prybar', false)
	var has_crystal = args.get('crystal', false)
	var has_portal = args.get('portal', false)
	var work_result = WorkResult.new()
	work_result.destroy_item_result(get_id(), false)
	if has_prybar:
		post_desc = "A prybar is found in the debris pile. Equipping this will help in clearing future debris."
		work_result.new_item_result("prybar", "res://items/EquipmentItem.gd", self, {'work_amounts': {WorkTypes.MANUAL_LABOR: 1.0},
			EquipmentItem.KEY_ATTUNE_MULTIPLIER: 0.1, # each attunement level is worth 10% bonus to the base work_amounts
			EquipmentItem.KEY_ATTUNE_PROGRESS_MULTIPLIER: 5, # each attunement level takes (level ^ 2) * 5 seconds of work to achieve
		})
	elif has_crystal:
		post_desc = "A shimmering crystal is found in the debris pile. It radiates a sense of power, but you're not sure what use it might be."
		work_result.new_item_result("impure vis crystal", "res://items/GemItem.gd", self, GemItem.get_resolve_item_args(0, 0, 1, Vis.TYPE_IMPURE))
	elif has_portal:
		post_desc = "The debris covering the portal is cleared - the room must have collapsed as you made your way through. The portal is dead and silent, but perhaps providing it with an energy source from this side might reopen it."
		work_result.new_item_result("dimensional portal", "res://entities/wizard_tower/TowerPortal.gd", self, {'_item_id': has_portal})
	else:
		post_desc = "A thankless job, completed."
	clear_task.set_description(pre_desc, post_desc)
	clear_task.set_work_result(work_result)

func resolve_completion_effects():
	var other_debris = find_sibling_items(func(item): 
		return item != self and item.get_script() == self.get_script())
	if other_debris.size() <= 0:
		Events.emit_goal_progress(PortalTutorialGoal.GOAL_ID, PortalTutorialGoal.GOAL_PORTAL_FOUND)
