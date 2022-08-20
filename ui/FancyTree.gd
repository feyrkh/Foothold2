extends Tree
class_name FancyTree

const BASE_PIXEL_HEIGHT = 35
const PIXELS_PER_ROW = 28
const MAX_PIXELS = 300

var root
@export var headers:Array[String]
@export var header_tooltips:Array
@export var formats:Array
# alignments should be filled with nulls (default left align), or HORIZONTAL_ALIGNMENT_CENTER, HORIZONTAL_ALIGNMENT_FILL, HORIZONTAL_ALIGNMENT_RIGHT
@export var alignments:Array

func _ready():
	columns = headers.size()
	clear_items()
	hide_root = true
	column_titles_visible = false

func clear_items():
	clear()
	root = create_item()
	var header = create_item(root)
	for i in range(headers.size()):
		header.set_custom_bg_color(i, Color.BLACK)
		header.set_custom_color(i, Color.WHITE_SMOKE)
		header.set_text(i, headers[i]+' ')
		if header_tooltips != null and i < header_tooltips.size() and header_tooltips[i] != null:
			header.set_tooltip(i, header_tooltips[i])
		if alignments != null and i < alignments.size() and alignments[i] != null:
			header.set_text_alignment(i, alignments[i])

func add_row(items_arr:Array, tooltips_arr:Variant = null) -> TreeItem:
	var row = create_item(root)
	for i in range(items_arr.size()):
		row.set_selectable(i, false)
		var format = null
		if formats != null and i < formats.size():
			format = formats[i]
		if i < items_arr.size() and items_arr[i] != null:
			if format != null and format != '':
				row.set_text(i, format % [items_arr[i]])
			else:
				row.set_text(i, items_arr[i])
		if tooltips_arr != null and i < tooltips_arr.size() and tooltips_arr[i] != null:
			row.set_tooltip(i, tooltips_arr[i])
		if alignments != null and i < alignments.size() and alignments[i] != null:
			row.set_text_alignment(i, alignments[i])
	custom_minimum_size.y = min(BASE_PIXEL_HEIGHT + (PIXELS_PER_ROW * (root.get_child_count()+1)), MAX_PIXELS)
	return row
