extends AreaItem

var explore_rooms_found = 0

func has_more_explore_locations():
	return explore_rooms_found < 1

func get_explore_work_party():
	match explore_rooms_found:
		0: 
			var work = Factory.work_party("Explore", Tags.WORK_PARTY_EXPLORE, {WorkTypes.EXPLORE: 3})
			var result:WorkResult = WorkResult.new()
			result.pre_complete_desc = "Step into the forbidding edifice, and begin to clear it."
			result.post_complete_desc = "Shove the creaking door open..."
			var chamber_id = IdManager.get_next_id(null)
			var portal_id = IdManager.get_next_id(null)
			Events.emit_signal('goal_item', PortalTutorialGoal.GOAL_ID, PortalTutorialGoal.EXPLORE_PARTY_ID, work.get_id())
			Events.emit_signal('goal_item', PortalTutorialGoal.GOAL_ID, PortalTutorialGoal.PORTAL_CHAMBER_ID, chamber_id)
			Events.emit_signal('goal_item', PortalTutorialGoal.GOAL_ID, PortalTutorialGoal.PORTAL_ID, portal_id)
			result.new_location_result("Portal Chamber",  get_id(), 10, {'_item_id': chamber_id}, "res://entities/wizard_tower/PortalChamber.gd")
			result.new_item_result("Scattered debris", "res://entities/wizard_tower/PortalDebris.gd", chamber_id, {'work': 5, 'prybar': true})
			result.new_item_result("Scattered debris", "res://entities/wizard_tower/PortalDebris.gd", chamber_id, {'work': 20, 'crystal': true})
			result.new_item_result("Scattered debris", "res://entities/wizard_tower/PortalDebris.gd", chamber_id, {'work': 60, 'portal': portal_id})
			work.set_work_result(result)
			#work.set_callback(WorkPartyItem.WORK_COMPLETE_CALLBACK, get_id(), 'complete_explore')
			work.set_callback(WorkPartyItem.RESOLVE_WORK_CALLBACK, get_id(), 'resolve_explore')
			return work
		_:
			return null

func resolve_explore(work_item):
	explore_rooms_found += 1

func get_explore_effort_needed():
	return 30 * (2 ** explore_rooms_found)
	
func get_description():
	return "This ancient tower is falling apart. Debris litters its corridors, the steps of the staircase "+\
		"that winds around the outside edge are wobbly, broken, or entirely missing, and doors are "+\
		"locked or blocked from the inside by falling masonry. Just exploring the interior will take "+\
		"time, to say nothing of the effort that any repairs will require."
