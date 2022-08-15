extends FancyTree

# Called when the node enters the scene tree for the first time.
func _ready():
	headers = ['Stat Name', 'Base', 'Total']
	header_tooltips = [' ', 'Value before any equipment bonuses or other buffs', 'Value after all modifiers are considered']
	formats = [null, '%.1f', '%.1f']
	super._ready()

func add_stat(stat:StatEntry):
	add_row([Stats.get_stat_name(stat.stat_type), stat.base, stat.get_stat_value()], [' ', ' ', ' '])
