extends GameItem
class_name CombatStyle

var equipment_type = Combat.EQUIP_HAND_TO_HAND
var stances:Array # of CombatStance, except in post_config
var __combatant

static func build(stances, equipment_type) -> CombatStyle:
	var result = CombatStyle.new()
	result.stances = stances
	result.equipment_type = equipment_type
	result.set_label(result.generate_random_name())
	return result

func post_config(c):
	if stances != null:
		stances = stances.map(func(c): return CombatStance.from_config(c))

# Called when creating object from WorkResult
func finish_resolve_item_result(args):
	pass # delete if not needed

func get_action_panel_scene_path()->String:
	return "res://items/FlexibleItemActions.tscn"

const ACTION_SECTIONS = ['Description', 'CombatStyle']
func get_action_sections()->Array:
	return ACTION_SECTIONS

const SELF_TAGS = {Tags.TAG_COMBAT_STYLE: true}
const ALLOWED_TAGS = {}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS
	
func get_description():
	return null

func generate_random_name()->String:
	var adjective_opts = [] # Bestial, Defensive, etc
	var attack_type_opts = [] # Striking, Smashing, Burning, etc
	var equipment_opts = [] # Fist, Edge, Spear, etc
	
	var total_attack_power = 0
	var total_defend_power = 0
	
	for stance in stances:
		for power_type in stance.base_power_per_damage_type.keys():
			if Combat.is_attack(power_type):
				total_attack_power += stance.base_power_per_damage_type.get(power_type, 0)
			else:
				total_defend_power += stance.base_power_per_damage_type.get(power_type, 0)
			var new_attack_type_opts = Combat.get_attack_type_name_opts(power_type, equipment_type, stance.base_power_per_damage_type.get(power_type, 0))
			var new_equipment_opts = Combat.get_equipment_name_opts(power_type, equipment_type, stance.base_power_per_damage_type.get(power_type, 0))
			if new_attack_type_opts != null and new_attack_type_opts.size() != 0:
				attack_type_opts.append(new_attack_type_opts)
			if new_equipment_opts != null and new_equipment_opts.size() != 0:
				equipment_opts.append(new_equipment_opts)
	adjective_opts.append(Combat.get_power_distribution_name_opts(total_attack_power, total_defend_power))
	
	if equipment_opts.is_empty(): equipment_opts = ['']
	if adjective_opts.is_empty(): adjective_opts = [["Unknown", "Generic", "Mediocre"]]
	if attack_type_opts.is_empty(): attack_type_opts = [[""]]
	
	return Util.generate_option_string([adjective_opts, attack_type_opts, equipment_opts, 'Style'])

func get_combatant():
	if __combatant == null:
		var possible_combatant = get_closest_nonfolder_parent()
		if possible_combatant.has_method('get_stats'):
			__combatant = possible_combatant
		else:
			push_error("Tried to use non-stat-having item as combatant for a CombatStyle: ", possible_combatant.get_label())
	return __combatant
