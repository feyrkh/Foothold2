extends FancyTree

# Called when the node enters the scene tree for the first time.
func _ready():
	headers = ['Status', 'Current', 'Max']
	formats = [null, '%.1f', '%.1f']
	super._ready()

func add_status_item(label:String, current:float, max:float):
	add_row([label, current, max])
