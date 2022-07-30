extends Goal
class_name PortalTutorialGoal

const GOAL_ID = 'portal_tut'

const GOAL_STARTED = 0
const GOAL_EXPLORE_PARTY_CREATED = 1
const GOAL_CHAMBER_EXPLORED = 2
const GOAL_DEBRIS_CLEARED = 3
const GOAL_PORTAL_ACTIVATED = 4

const EXPLORE_PARTY_ID = 'eid'
const PORTAL_CHAMBER_ID = 'cid'
const PORTAL_ID = 'pid'

var goal_state = GOAL_STARTED
var debris_left = 3

func setup():
	var wizardTower:AreaItem = Factory.area("Ancient tower", 'res://entities/wizard_tower/WizardTower.gd')
	wizardTower.owner_lock_id = 'wiztower'
	wizardTower.explore_difficulty = 15
	Events.emit_signal('add_game_item', wizardTower, null, false)
	var pc:PcItem = Factory.pc('A wanderer')
	Factory.place_item(pc, wizardTower)

func get_default_label():
	return 'Explore the tower'

func get_goal_id():
	return GOAL_ID

func on_important_item_create(item_key, game_item):
	match item_key:
		EXPLORE_PARTY_ID: 
			Events.emit_signal('goal_progress', get_goal_id(), GOAL_EXPLORE_PARTY_CREATED)
		PORTAL_CHAMBER_ID: 
			Events.emit_signal('goal_progress', get_goal_id(), GOAL_CHAMBER_EXPLORED)
		PORTAL_ID: 
			Events.emit_signal('goal_progress', get_goal_id(), GOAL_PORTAL_ACTIVATED)
	
func on_important_item_delete(item_key, game_item):
	pass

func on_goal_progress(new_progress):
	goal_state = new_progress
	var portal_chamber:GameItem = get_important_item(PORTAL_CHAMBER_ID)
	if portal_chamber:
		portal_chamber.tutorial_goal_state = new_progress
		portal_chamber.refresh_action_panel()
	match goal_state:
		GOAL_PORTAL_ACTIVATED: print("Time to create the portal object")
	refresh_action_panel()
		
func get_description():
	match goal_state:
		GOAL_STARTED: return "As the first scout to pass through a portal into a new world, the scout arrives disoriented and weak in a dilapidated tower.\nThey take a moment to gather their thoughts, and make a plan to explore their new surroundings.\n\n- Form an exploration work party"
		GOAL_EXPLORE_PARTY_CREATED: return "With the exploration plan firmly in mind, all that remains is to execute it.\n\n- Assign the scout to an exploration party\n- Wait until exploration is complete"
		GOAL_CHAMBER_EXPLORED: return "The room is choked with debris, but you see what looks like a return portal behind a particularly large pile of rubble.\n\n- Clear all the debris"
