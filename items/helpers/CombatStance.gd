extends RefCounted
class_name CombatStance

var damage_types # either a damage type int (see Combat.PHYSICAL_ATTACK for example), or an array of them
var base_power_per_damage_type := {}
var fatigue := 0.0
var fatigue_heal := 0.1
var scaling_stat := Stats.STRENGTH
var stat_min := 100
var scale_multiplier := 0.1

static func from_config(c):
	var result = CombatStance.new()
	Config.config(result, c)
	return result

static func build(damage_types, base_power_per_damage_type:Dictionary, scaling_stat:int, stat_min:float, scale_multiplier:float):
	var result = CombatStance.new()
	result.damage_types = damage_types
	result.base_power_per_damage_type = base_power_per_damage_type
	result.scaling_stat = scaling_stat
	result.stat_min = stat_min
	result.scale_multiplier = scale_multiplier
	

func get_stat_scaling_multiplier(scaling_stat_value:float)->float:
	return (1 +((scaling_stat_value - stat_min) / stat_min) * scale_multiplier)

