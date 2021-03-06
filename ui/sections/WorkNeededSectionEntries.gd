extends Tree

const BASE_PIXEL_HEIGHT = 35
const PIXELS_PER_ROW = 28
const MAX_PIXELS = 300

var root

# Called when the node enters the scene tree for the first time.
func _ready():
	set_column_title(0, 'Effort Type')
	set_column_title(1, 'Needed')
	set_column_title(2, 'Provided')
	clear_items()
	hide_root = true


func clear_items():
	clear()
	root = create_item()

func add_work_amount(needed:WorkAmount, provided:WorkAmount):
	var item = create_item(root)
	item.set_selectable(0, false)
	item.set_selectable(1, false)
	item.set_text(0, needed.label)
	item.set_text(1, "%.1f"%[needed.get_effort()])
	if provided != null:
		item.set_text(2, "%.1f"%[provided.get_effort()])
	else:
		item.set_text(2, '')
	custom_minimum_size.y = min(BASE_PIXEL_HEIGHT + (PIXELS_PER_ROW * (root.get_child_count()+1)), MAX_PIXELS)
	visible = false
	call_deferred("set_visible", true)
