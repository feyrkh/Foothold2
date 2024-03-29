extends AreaItem

const TASK_EXPLORE_ROOM = 'explore_room'

var explore_rooms_found = 0

func get_work_task_options(requestor:GameItem) -> Dictionary:
	var result = {}
	if has_more_explore_locations():
		result[TASK_EXPLORE_ROOM] = WorkTaskOption.build(TASK_EXPLORE_ROOM, "Explore the tower", get_id(), "Uncover additional rooms, ancient artifacts, and the like.", WorkTask.LOCATION_INSIDE)
	return self.work_task_list.filter_task_options(result, requestor)

func build_work_task(next_task:WorkTaskOption, contributor:GameItem) -> WorkTask:
	match next_task.get_id():
		TASK_EXPLORE_ROOM: return build_explore_task()
		_: return null

func has_more_explore_locations():
	return explore_rooms_found < 1

func build_explore_task() -> WorkTask:
	match explore_rooms_found:
		0: 
			var work = WorkTask.new()
			work.set_description("Step into the forbidding edifice, and begin to clear it.", "Shove the creaking door open...")
			work.set_work_needed({WorkTypes.EXPLORE: 15})
			var result:WorkResult = WorkResult.new()
			var chamber_id = IdManager.get_next_id(null)
			var portal_id = IdManager.get_next_id(null)
			Events.emit_signal('goal_item', PortalTutorialGoal.GOAL_ID, PortalTutorialGoal.PORTAL_CHAMBER_ID, chamber_id)
			Events.emit_signal('goal_item', PortalTutorialGoal.GOAL_ID, PortalTutorialGoal.PORTAL_ID, portal_id)
			result.new_location_result("Portal Chamber",  get_id(), 10, {'_item_id': chamber_id}, "res://entities/wizard_tower/PortalChamber.gd")
			result.new_item_result("Pile of tools", "res://entities/wizard_tower/PortalDebris.gd", chamber_id, {'work': 5, 'prybar': true})
			result.new_item_result("Scattered debris", "res://entities/wizard_tower/PortalDebris.gd", chamber_id, {'work': 20, 'crystal': true})
			result.new_item_result("Large debris", "res://entities/wizard_tower/PortalDebris.gd", chamber_id, {'work': 60, 'portal': portal_id})
			result.on_create_callback_result(get_id(), 'start_first_explore')
			result.on_complete_callback_result(get_id(), 'complete_first_explore')
			result.on_resolve_callback_result(get_id(), 'resolve_explore')
			result.goal_progress(PortalTutorialGoal.GOAL_ID, PortalTutorialGoal.GOAL_CHAMBER_EXPLORED)
			work.set_work_result(result)
			return work
		_: 
			return null

func start_first_explore():
	Events.goal_progress.emit(PortalTutorialGoal.GOAL_ID, PortalTutorialGoal.GOAL_EXPLORE_PARTY_CREATED)

func complete_first_explore():
	Events.goal_progress.emit(PortalTutorialGoal.GOAL_ID, PortalTutorialGoal.GOAL_EXPLORE_PARTY_WORK_COMPLETED)

func resolve_explore():
	explore_rooms_found += 1

func get_explore_effort_needed():
	return 30 * (2 ** explore_rooms_found)
	
func get_description():
	return "This ancient tower is falling apart. Debris litters its corridors, the steps of the staircase "+\
		"that winds around the outside edge are wobbly, broken, or entirely missing, and doors are "+\
		"locked or blocked from the inside by falling masonry. Just exploring the interior will take "+\
		"time, to say nothing of the effort that any repairs will require."
