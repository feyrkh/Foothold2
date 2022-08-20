extends FancyTree

# Called when the node enters the scene tree for the first time.
func _ready():
	headers = ['Status', 'Current', 'Max', 'Regen']
	alignments = [null, HORIZONTAL_ALIGNMENT_RIGHT, HORIZONTAL_ALIGNMENT_RIGHT, HORIZONTAL_ALIGNMENT_RIGHT]
	super._ready()

func add_status_item(label:String, current:float, max:float, regen:float=0.0):
	var regen_str = ' ('+')' if regen != 0 else ''
	add_row([label, Numbers.format_number(current), Numbers.format_number(max), Numbers.format_rate(regen)],
		null)
