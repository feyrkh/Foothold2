extends WorkPartyItem

# When all debris in the room is cleared, a portal will open

func finish_resolve_item_result(args):
	init_work_party("Scattered debris", Tags.WORK_PARTY_MANUAL_LABOR, {WorkTypes.MANUAL_LABOR: args.get('work', 0)})
	var has_prybar = args.get('prybar', false)
	var has_crystal = args.get('crystal', false)
	var has_portal = args.get('portal', false)
	var work_result = WorkResult.new()
	work_result.pre_complete_desc = "Broken and crumbled masonry, splintered timbers, and other assorted refuse."
	if has_prybar:
		work_result.post_complete_desc = "A prybar is found in the debris pile. Equipping this will help in clearing future debris."
		work_result.new_item_result("prybar", "res://items/EquipmentItem.gd", self, {'work_amounts': {WorkTypes.MANUAL_LABOR: 1.0},
			EquipmentItem.KEY_ATTUNE_MULTIPLIER: 0.1, # each attunement level is worth 10% bonus to the base work_amounts
			EquipmentItem.KEY_ATTUNE_PROGRESS_MULTIPLIER: 5, # each attunement level takes (level ^ 2) * 5 seconds of work to achieve
		})
	elif has_crystal:
		work_result.post_complete_desc = "A shimmering crystal is found in the debris pile. It radiates a sense of power, but you're not sure what use it might be."
		work_result.new_item_result("impure vis crystal", "res://items/GemItem.gd", self, GemItem.get_resolve_item_args(0, 0, 1, Vis.TYPE_IMPURE))
	else:
		work_result.post_complete_desc = "A thankless job, completed."
	set_work_result(work_result)

func resolve_completion_effects():
	var other_debris = find_sibling_items(func(item): 
		return item != self and item.get_script() == self.get_script())
	if other_debris.size() <= 0:
		Events.emit_goal_progress(PortalTutorialGoal.GOAL_ID, PortalTutorialGoal.GOAL_PORTAL_ACTIVATED)
	super.resolve_completion_effects()
