extends Section

var style:CombatStyle
var stance_sections:Array = []

func _ready():
	style = get_game_item()
	if !style:
		push_error('Null or non-CombatStyle item for CombatStyleSection: ', null if !get_game_item() else get_game_item().get_label())
		return
	var i = 0
	for stance in style.stances:
		i += 1
		var stance_section:CombatStanceEntry = preload('res://ui/sections/combat/CombatStanceEntry.tscn').instantiate()
		stance_section.name = 'Stance '+i
		stance_section.stance = stance
		stance_section.combatant = style.get_combatant()
		stance_sections.append(stance_section)
		add_child(stance_section)

func refresh():
	if !style:
		return
