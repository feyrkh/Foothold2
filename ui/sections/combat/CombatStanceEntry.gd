extends Container
class_name CombatStanceEntry

@onready var FatigueHeader = find_child('FatigueHeader')
@onready var FatigueAmt = find_child('FatigueAmt')
@onready var AttackTypes = find_child('AttackTypes')
@onready var DefendTypes = find_child('DefendTypes')

var stance:CombatStance
var combatant:GameItem

var attack_entries := []
var defend_entries := []

func _ready():
	stance.fatigue_updated.connect(update_fatigue_amount)
	stance.base_power_updated.connect(refresh)
	if combatant.has_signal('stats_updated'):
		combatant.stats_updated.connect(refresh)
	var stat:StatEntry = combatant.get_stat(stance.scaling_stat)
	stat.stat_total_updated.connect(scaling_stat_updated)
	for damage_type in stance.damage_types:
		if Combat.is_attack(damage_type):
			attack_entries.append(damage_type)
		else:
			defend_entries.append(damage_type)
	if attack_entries.is_empty():
		find_child('AttackHeader').visible = false
		find_child('AttackTypes').visible = false
	if defend_entries.is_empty():
		find_child('DefendHeader').visible = false
		find_child('DefendTypes').visible = false
	find_child('StanceName').text = stance.stance_name
	refresh()

func scaling_stat_updated(stat_entry, old_total, new_total):
	refresh()

func refresh():
	if stance.fatigue <= 0:
		FatigueHeader.visible = false
		FatigueAmt.visible = false
	else:
		FatigueHeader.visible = true
		FatigueAmt.visible = true
		update_fatigue_amount(stance.fatigue)
	var total_damage = stance.get_stance_value(combatant)
	AttackTypes.text = ", ".join(attack_entries.map(damage_type_desc.bind(total_damage)))
	DefendTypes.text = ", ".join(defend_entries.map(damage_type_desc.bind(total_damage)))

func damage_type_desc(damage_type, total_damage):
	return Numbers.format_number(total_damage[damage_type])+' '+Combat.get_damage_short_element(damage_type)
	
func update_fatigue_amount(amt:float):
	FatigueAmt.text = round(amt*100)+"%"
