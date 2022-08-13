extends Object
class_name Combat

const PHYSICAL_ATTACK = 0
const PHYSICAL_DEFEND = 1
const IMPURE_VIS_ATTACK = 2
const IMPURE_VIS_DEFEND = 3 

static func is_attack(damage_type:int)->bool:
	return posmod(damage_type, 2) == 0

static func is_defend(damage_type:int) -> bool:
	return posmod(damage_type, 2) == 1

const EQUIP_HAND_TO_HAND = 0

static func get_equipment_description(equip_type:int)->String:
	match equip_type:
		EQUIP_HAND_TO_HAND: return "hand-to-hand"
		_: return "unknown"

static func get_attack_type_name_opts(power_type, equipment_type, attack_power) -> Array[String]:
	var attack_type_opts = []
	match power_type:
		Combat.PHYSICAL_ATTACK: attack_type_opts.append_array(['Striking', null, 'Smashing'])
		Combat.PHYSICAL_DEFEND: attack_type_opts.append_array(['Wall', null, 'Guard'])
		Combat.IMPURE_VIS_ATTACK: 
			attack_type_opts.append_array(['Force', 'Vis', 'Shoving'])
		Combat.IMPURE_VIS_DEFEND:
			attack_type_opts.append_array(['Shell', 'Imbued'])
		_:
			push_error('Unexpected power_type when generating attack_type_name in a new style: ', power_type)
			attack_type_opts.append(null)
	return attack_type_opts

static func get_equipment_name_opts(power_type, equipment_type, attack_power) -> Array[String]:
	var equipment_opts = []
	match power_type:
		Combat.PHYSICAL_ATTACK: pass
		Combat.PHYSICAL_DEFEND: pass
		Combat.IMPURE_VIS_ATTACK: 
			equipment_opts.append_array(['Bolt', 'Wave', 'Fan', 'Will'])
		Combat.IMPURE_VIS_DEFEND:
			equipment_opts.append_array(['Cloak', 'Domain', 'Shell'])
		_:
			push_error('Unexpected power_type when generating equipment_name in a new style: ', power_type)
	match equipment_type:
		Combat.EQUIP_HAND_TO_HAND: equipment_opts.append_array(['Fist', 'Foot', 'Kick', 'Leg', 'Hand', 'Grapple', 'Brawl', 'Grip', 'Knee', 'Elbow'])
		_: 
			push_error('Unexpected equipment_type when generating equipment_name in a new style: ', equipment_type)
			equipment_opts.append_array(['Style'])
	return equipment_opts

static func get_power_distribution_name_opts(total_attack_power, total_defend_power):
	var adjective_opts = []
	total_attack_power = total_attack_power / (total_attack_power + total_defend_power)
	total_defend_power = total_defend_power / (total_attack_power + total_defend_power)
	if total_attack_power == 0:
		adjective_opts.append_array(['Pure Defense', 'Stonewalling', 'Cowardly'])
	elif total_attack_power < 0.25:
		adjective_opts.append_array(['Defensive', 'Guarding', 'Slippery'])
	elif total_attack_power < 0.5:
		adjective_opts.append_array(['Drunken', 'Cautious', 'Reserved'])
	elif total_attack_power < 0.75:
		adjective_opts.append_array(['Striking', 'Balanced', 'Opposing'])
	elif total_attack_power < 1.0:
		adjective_opts.append_array(['Offensive', 'Aggressive', 'Rushing'])
	else:
		adjective_opts.append_array(['Brutal', 'Bestial', 'Demonic'])
	return adjective_opts
