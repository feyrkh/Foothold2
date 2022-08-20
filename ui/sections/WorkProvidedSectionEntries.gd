extends FancyTree

# Called when the node enters the scene tree for the first time.
func _ready():
	headers = ['Effort Type', 'Amount']
	alignments = [null, HORIZONTAL_ALIGNMENT_RIGHT]
	super._ready()

func add_work_amount(work_amount:WorkAmount):
	add_row([work_amount.label, Numbers.format_rate(work_amount.get_total_effort())], 
		[WorkTypes.tooltip_desc(work_amount.work_type), work_amount.get_helpers_description()])
