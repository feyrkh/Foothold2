extends HBoxContainer
class_name DropdownMenu

signal item_selected(idx, metadata)

@export var unselected_text:String = '(select)'
@export var populate_callback:Callable # should return an array of [label, metadata] entries
var selected_idx:int = -1
var selected_metadata = null
var selected_text = null
var menu:ScreenLimitedPopupMenu

func _ready():
	$DropdownButton.connect('pressed', show_dropdown)
	$DropdownLabel.connect('pressed', show_dropdown)

func reset():
	selected_idx = -1
	selected_metadata = null
	$DropdownLabel.text = unselected_text

func setup(unselected_text:String, populate_callback:Callable, selected_idx:int=-1):
	self.unselected_text = unselected_text
	self.populate_callback = populate_callback
	$DropdownLabel.text = unselected_text

func populate_dropdown():
	if menu:
		menu.visible = false
		menu.queue_free()
	menu = preload('res://util/ScreenLimitedPopupMenu.tscn').instantiate()
	menu.min_size.y = 10
	menu.size.y = 10
	add_child(menu)
	menu.id_pressed.connect(select_item)
	for item in populate_callback.call():
		menu.add_item(item[0])
		menu.set_item_metadata(-1, item[1])
	if selected_idx != -1:
		selected_metadata = menu.get_item_metadata(selected_idx)
		$DropdownLabel.text = menu.get_item_text(selected_idx)
	else:
		$DropdownLabel.text = unselected_text

func show_dropdown():
	populate_dropdown()
	var button = $DropdownButton
	var label = $DropdownLabel
	menu.min_size.x = label.size.x + button.size.x + 8
	menu.size.x = menu.min_size.x
	menu.popup_on_screen(label.global_position + Vector2(0, label.size.y+1) )

func select_item(idx):
	selected_idx = idx
	selected_metadata = menu.get_item_metadata(selected_idx)
	selected_text = $DropdownLabel.text
	$DropdownLabel.text = menu.get_item_text(selected_idx)
	item_selected.emit(selected_idx, selected_metadata)
