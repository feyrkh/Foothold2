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

static func build(damage_types, base_power_per_damage_type:Dictionary, scaling_stat:int, stat_min:float, scale_multiplier:float, stance_name:String):
	var result = CombatStance.new()
	result.damage_types = damage_types if damage_types is Array else [damage_types]
	result.damage_types.sort() 
	result.base_power_per_damage_type = base_power_per_damage_type
	result.scaling_stat = scaling_stat
	result.stat_min = stat_min
	result.scale_multiplier = scale_multiplier
	result.stance_name = stance_name
	return result

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
	
	
