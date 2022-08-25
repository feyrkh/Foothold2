extends FancyTree

# Called when the node enters the scene tree for the first time.
func _ready():
	headers = ['Effort Type', 'Needed', 'Provided']
	alignments = [null, HORIZONTAL_ALIGNMENT_RIGHT, HORIZONTAL_ALIGNMENT_RIGHT]
	Events.game_tick.connect(refresh_work_amounts)
	super._ready()

func add_work_amount(needed:WorkAmount, provided:WorkAmount):
	var item = add_row([needed.label, '', ''], [WorkTypes.tooltip_desc(needed.work_type)])
	item.set_metadata(0, needed)
	update_work_amount(needed, provided, item)
	visible = false
	call_deferred("set_visible", true)

func update_work_amount(needed:WorkAmount, provided:WorkAmount, item:TreeItem):
	item.set_text(1, Numbers.format_number(needed.get_total_effort()))
	item.set_metadata(1, needed.get_total_effort())
	item.set_tooltip(1, needed.get_helpers_description())
	if provided != null:
		item.set_text(2, Numbers.format_rate(provided.get_total_effort()))
		item.set_tooltip(2, provided.get_helpers_description())
	else:
		item.set_text(2, '')
		item.set_tooltip(2, '')

func refresh_work_amounts():
	var root = get_root()
	var cur_item = root.get_first_child()
	while cur_item != null:
		var needed = cur_item.get_metadata(0)
		if !needed:
			cur_item = cur_item.get_next()
			continue
		var needed_total_effort = needed.get_total_effort()
		if needed_total_effort <= 0:
			var old_item = cur_item
			cur_item = cur_item.get_next()
			continue
		if needed_total_effort != cur_item.get_metadata(1):
			cur_item.set_text(1, Numbers.format_number(needed.get_total_effort()))
			cur_item.set_metadata(1, needed.get_total_effort())
		cur_item = cur_item.get_next()
