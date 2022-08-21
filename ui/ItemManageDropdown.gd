extends Control

signal rename_item(old_name, new_name)
signal new_folder(folder_name)
signal delete_item()

const CMD_RENAME = 1
const CMD_NEW = 2
const CMD_DELETE = 3

func _ready():
	find_child('ItemManageButton').connect('pressed', _on_item_manage_button_pressed)
	find_child('PopupMenu').connect('id_pressed', _on_popup_menu_id_pressed)

func setup_dropdown(game_ui, game_item):
	if game_item.can_create_subfolder():
		connect('new_folder', game_ui.new_folder.bind(game_item))
		find_child('PopupMenu').add_item('New folder', CMD_NEW)
	if game_item.can_rename():
		connect('rename_item', game_item.set_label)
		find_child('PopupMenu').add_item('Rename', CMD_RENAME)
	if game_item.can_delete():
		connect('delete_item', game_item.delete.bind(true))
		find_child('PopupMenu').add_item('Delete', CMD_DELETE)
	if find_child('PopupMenu').item_count == 0:
		queue_free()

func _on_popup_menu_id_pressed(id):
	match id:
		CMD_NEW:
			var popup:PopupPanel = preload("res://ui/popup/GetStringPopup.tscn").instantiate()
			popup.set_prompt("Create a new folder?")
			add_child(popup)
			popup.connect('ok_button_pressed', func(folder_name):emit_signal('new_folder', folder_name))
			popup.popup_centered()
		CMD_RENAME:
			var popup:PopupPanel = preload("res://ui/popup/GetStringPopup.tscn").instantiate()
			popup.set_prompt("Rename this item?")
			add_child(popup)
			popup.connect('ok_button_pressed', func(folder_name):emit_signal('rename_item', folder_name))
			popup.popup_centered()
		CMD_DELETE:
			var popup:PopupPanel = preload("res://ui/popup/ConfirmPopup.tscn").instantiate()
			popup.set_prompt("Are you sure you want to delete this?")
			add_child(popup)
			popup.connect('ok_button_pressed', func():emit_signal('delete_item'))
			popup.popup_centered()
			

func _on_item_manage_button_pressed():
	var popup_menu:ScreenLimitedPopupMenu = find_child('PopupMenu')
	popup_menu.popup_on_screen(self.global_position + Vector2(0, size.y))
