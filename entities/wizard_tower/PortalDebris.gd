extends WorkPartyItem

# When all debris in the room is cleared, a portal will open

func finish_resolve_item_result(args):
	init_work_party("Scattered debris", Tags.WORK_PARTY_MANUAL_LABOR, {WorkTypes.MANUAL_LABOR: args.get('work', 0)})
	var work_result = WorkResult.new()
	work_result.pre_complete_desc = "Broken and crumbled masonry, splintered timbers, and other assorted refuse."
	set_work_result(work_result)
	auto_resolve = true

func resolve_completion_effects():
	var other_debris = find_sibling_items(func(item): 
		return item != self and item.get_script() == self.get_script())
	if other_debris.size() <= 0:
		Events.emit_goal_progress(PortalTutorialGoal.GOAL_ID, PortalTutorialGoal.GOAL_PORTAL_ACTIVATED)
	super.resolve_completion_effects()
