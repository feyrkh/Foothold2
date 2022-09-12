extends RefCounted
class_name CombatStance

signal fatigue_updated(new_amt)
signal base_power_updated()

var damage_types # either a damage type int (see Combat.PHYSICAL_ATTACK for example), or an array of them
var base_power_per_damage_type := {}
var fatigue := 0.0:
	set(val):
		if val != fatigue:
			fatigue = val
			fatigue_updated.emit(val)
var fatigue_heal := 0.1
var scaling_stat := Stats.STRENGTH
var stat_min := 100
var scale_multiplier := 0.1
var stance_name

static func from_config(c):
	var result = CombatStance.new()
	Config.config(result, c)
	return result

static func build(damage_types, base_power_per_damage_type:Dictionary, scaling_stat:int, stat_min:float, scale_multiplier:float, equipment_type):
	var result = CombatStance.new()
	result.damage_types = damage_types if damage_types is Array else [damage_types]
	result.damage_types.sort() 
	var attack_names = []
	var nouns = []
	var adjs = []
	var verbs = []
	var attack_power = 0
	var defend_power = 0
	for damage_type in damage_types:
		if Combat.is_attack(damage_type):
			attack_power += base_power_per_damage_type[damage_type]
		else:
			defend_power += base_power_per_damage_type[damage_type]
		attack_names.append_array(Combat.get_damage_type_attack_names(damage_type))
		nouns.append_array(Combat.get_damage_type_nouns(damage_type))
		adjs.append_array(Combat.get_damage_type_adjectives(damage_type))
		verbs.append_array(Combat.get_damage_type_verbs(damage_type))
	var balance = get_balance(attack_power, defend_power)
	attack_names.append_array(Combat.get_equipment_type_attack_names(equipment_type, balance))
	nouns.append_array(Combat.get_equipment_type_nouns(equipment_type, balance))
	adjs.append_array(Combat.get_equipment_type_adjectives(equipment_type, balance))
	verbs.append_array(Combat.get_equipment_type_verbs(equipment_type, balance))
	result.base_power_per_damage_type = base_power_per_damage_type
	attack_names.append(Combat.get_scaling_stat_attack_names(scaling_stat, balance))
	nouns.append(Combat.get_scaling_stat_nouns(scaling_stat, balance))
	adjs.append(Combat.get_scaling_stat_adjectives(scaling_stat, balance))
	verbs.append(Combat.get_scaling_stat_verbs(scaling_stat, balance))
	result.scaling_stat = scaling_stat
	result.stat_min = stat_min
	result.scale_multiplier = scale_multiplier
	result.stance_name = result.generate_stance_name(attack_names, nouns, adjs, verbs)
	return result

static func get_balance(attack_power, defend_power):
	var pct = attack_power / (attack_power + defend_power)
	var balance
	if pct < 0.35: balance = 'defend'
	elif pct > 0.65: balance = 'attack'
	else: balance = 'balance'

func get_stat_scaling_multiplier(combatant:GameItem)->float:
	if combatant == null:
		return 1.0
	var scaling_stat_value = combatant.get_stat(scaling_stat)
	if scaling_stat_value == null:
		scaling_stat_value = 0
	else:
		scaling_stat_value = scaling_stat_value.get_stat_value()
	return (1 + (((scaling_stat_value - stat_min) / stat_min) * scale_multiplier))

func get_stance_value(combatant:GameItem)->Dictionary:
	if combatant == null:
		push_error('Null combatant when checking stance value: ', self.get_label())
		return {}
	var result = {}
	var multiplier = get_stat_scaling_multiplier(combatant) * (1.0 - min(1.0, fatigue))
	for damage_type in damage_types:
		result[damage_type] = multiplier * base_power_per_damage_type[damage_type]
	return result

func generate_stance_name(attacks=[], nouns=[], adjs=[], verbs=[]):
	var formats = ['$a $x', '$v $x', '$x of $ns', '$v $a $x', '$a $n $x', '$v $x of the $ns']
	return Util.format_with_options(Util.choose_nested_option(formats, '$v $a $n'), {'$n': nouns, '$a': adjs, '$v': verbs, '$x': attacks})
		
