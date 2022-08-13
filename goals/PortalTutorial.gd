extends Goal
class_name PortalTutorialGoal

const GOAL_ID = 'portal_tut'

const GOAL_STARTED = 0
const GOAL_EXPLORE_PARTY_CREATED = 1
const GOAL_CHAMBER_EXPLORED = 2
const GOAL_DEBRIS_CLEARED = 3
const GOAL_PORTAL_FOUND = 4
const GOAL_PORTAL_ACTIVATED = 5

const EXPLORE_PARTY_ID = 'eid'
const PORTAL_CHAMBER_ID = 'cid'
const PORTAL_ID = 'pid'

var goal_state = GOAL_STARTED
var debris_left = 3

func _ready():
	super._ready()
	Events.game_tick.connect(on_game_tick)

func setup():
	var wizardTower:AreaItem = Factory.area("Ancient tower", 'res://entities/wizard_tower/WizardTower.gd')
	wizardTower.owner_lock_id = 'wiztower'
	wizardTower.explore_difficulty = 15
	Events.emit_signal('add_game_item', wizardTower, null, false)
	var pc:PcItem = Factory.pc('A wanderer')
	Factory.place_item(pc, wizardTower)

func on_game_tick():
	match goal_state:
		GOAL_PORTAL_FOUND:
			var portal = get_important_item(PORTAL_ID)
			if portal and portal.get_stability() > 0:
				print('Portal is powered')
				Events.goal_progress.emit(GOAL_ID, GOAL_PORTAL_ACTIVATED)

func get_default_label():
	return 'Reopen the portal'

func get_goal_id():
	return GOAL_ID

func on_important_item_create(item_key, game_item):
	match item_key:
		EXPLORE_PARTY_ID: 
			Events.emit_signal('goal_progress', get_goal_id(), GOAL_EXPLORE_PARTY_CREATED)
		PORTAL_CHAMBER_ID: 
			Events.emit_signal('goal_progress', get_goal_id(), GOAL_CHAMBER_EXPLORED)
		PORTAL_ID: 
			Events.emit_signal('goal_progress', get_goal_id(), GOAL_PORTAL_FOUND)
	
func on_important_item_delete(item_key, game_item):
	pass

func on_goal_progress(new_progress):
	goal_state = new_progress
	var portal_chamber:GameItem = get_important_item(PORTAL_CHAMBER_ID)
	if portal_chamber:
		portal_chamber.tutorial_goal_state = new_progress
		portal_chamber.refresh_action_panel()
	if new_progress == GOAL_PORTAL_ACTIVATED:
		completed = true
	refresh_action_panel()

func get_description():
	match goal_state:
		GOAL_STARTED: return "As the first scout to pass through a portal into a new world, you arrive disoriented and weak in a dilapidated tower.\nYou take a moment to gather your thoughts, and make a plan to explore their new surroundings.\n\n- Form an exploration work party"
		GOAL_EXPLORE_PARTY_CREATED: return "With the exploration plan firmly in mind, all that remains is to execute it.\n\n- Drag & drop the scout into an exploration work party\n- Wait until exploration is complete"
		GOAL_CHAMBER_EXPLORED: return "The room is choked with debris, but you see what looks like a return portal behind a particularly large pile of rubble.\n\n- Clear all the debris"
		GOAL_PORTAL_FOUND: return "You've cleared the portal you came through. It seems undamaged, but it appears the instability caused by your transfer was so high that the tower was severely damaged, and the portal has been completely drained of power.\n\n- Find a power source and place it into the portal to stabilize it."
		GOAL_PORTAL_ACTIVATED: return "The portal is stabilized, at least a bit. You can send supplies back home easily enough, but objects sent through the portal in the other direction require more energy, as they are traveling from a low-energy plane to a high-energy plane."

func get_goal_reward() -> WorkResult:
	match goal_state:
		GOAL_PORTAL_ACTIVATED: 
			var reward := WorkResult.new()
			reward.new_item_result("unarmed combat manual", "res://items/CombatManual.gd", get_important_item(PORTAL_ID), {
				CombatManual.KEY_STANCE_COUNT: 4,
				CombatManual.KEY_STANCE_COUNT_VARIANCE: 0.7,
				CombatManual.KEY_EQUIPMENT_TYPE: Combat.EQUIP_HAND_TO_HAND,
				CombatManual.KEY_BASE_POWER: 10,
				CombatManual.KEY_DAMAGE_TYPES: [Combat.PHYSICAL_ATTACK, Combat.PHYSICAL_DEFEND, {Combat.PHYSICAL_ATTACK:5, Combat.PHYSICAL_DEFEND:2}, {Combat.PHYSICAL_ATTACK:2, Combat.PHYSICAL_DEFEND:5}, {Combat.PHYSICAL_ATTACK:5, Combat.PHYSICAL_DEFEND:5}, Combat.PHYSICAL_ATTACK, Combat.PHYSICAL_ATTACK],
				CombatManual.KEY_STANCE_VARIANCE: 0,
				CombatManual.KEY_SCALING_STATS: [Stats.STRENGTH, Stats.STRENGTH, Stats.STRENGTH, Stats.STRENGTH, Stats.STRENGTH, Stats.AGILITY, Stats.AGILITY, Stats.AGILITY, Stats.CONSTITUTION, Stats.WILLPOWER],
				CombatManual.KEY_STAT_MIN: 100,
				CombatManual.KEY_SCALING_MULTIPLIER: 0.1,
			})
			reward.new_item_result("research notes: vis", "res://entities/wizard_tower/VisResearchNotes.gd", get_important_item(PORTAL_ID))
			return reward
		_: return null
