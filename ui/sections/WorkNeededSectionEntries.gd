extends FancyTree

# Called when the node enters the scene tree for the first time.
func _ready():
	headers = ['Effort Type', 'Needed', 'Provided']
	formats = [null, '%.1f', '%.1f']
	super._ready()

func add_work_amount(needed:WorkAmount, provided:WorkAmount):
	var item = add_row([needed.label, '', ''], [WorkTypes.tooltip_desc(needed.work_type)])
	update_work_amount(needed, provided, item)
	visible = false
	call_deferred("set_visible", true)

func update_work_amount(needed:WorkAmount, provided:WorkAmount, item:TreeItem):
	item.set_text(1, formats[1]%[needed.get_total_effort()])
	item.set_tooltip(1, needed.get_helpers_description())
	if provided != null:
		item.set_text(2, formats[2]%[provided.get_total_effort()])
		item.set_tooltip(2, provided.get_helpers_description())
	else:
		item.set_text(2, '')
		item.set_tooltip(2, '')
