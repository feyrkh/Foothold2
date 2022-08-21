extends Control
class_name DropdownMenu

signal item_selected(idx, metadata)

@export var populate_on_ready:bool = false
@export var populate_callback:Callable # should return an array of [label, metadata] entries

func _ready():
	if populate_on_ready:
		populate_dropdown()
	$DropdownButton.connect('pressed', show_dropdown)
	$DropdownMenu.connect('id_pressed', select_item)

func populate_dropdown():
	var menu:ScreenLimitedPopupMenu = $DropdownMenu
	menu.clear()
	for item in populate_callback.call():
		menu.add_item(item[0])
		menu.set_item_metadata(-1, item[1])

func show_dropdown():
	if !populate_on_ready:
		populate_dropdown()
	var button = $DropdownButton
	var label = $DropdownLabel
	var popup = $DropdownMenu
	popup.min_size.x = label.size.x + button.size.x
	popup.size.x = popup.min_size.x
	popup.popup_on_screen(button.global_position + Vector2(-label.size.x, button.size.y) )

func select_item(idx):
	item_selected.emit(idx, $DropdownMenu.get_item_metadata(idx))
