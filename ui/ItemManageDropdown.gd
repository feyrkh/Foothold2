extends Control

signal rename_item(old_name, new_name)
signal new_folder(folder_name)
signal delete_item(keep_children)

const CMD_RENAME = 1
const CMD_NEW = 2
const CMD_DELETE = 3

func setup_dropdown(game_ui, game_item, action_panel):
	if game_item.can_create_subfolder():
		connect('new_folder', game_ui.new_folder, [game_item])
		$PopupMenu.add_item('New folder', CMD_NEW)
	if game_item.can_rename():
		connect('rename_item', game_item.set_label)
		$PopupMenu.add_item('Rename', CMD_RENAME)
	if game_item.can_delete():
		connect('delete_item', game_ui.delete_item, [game_item])
		$PopupMenu.add_item('Delete', CMD_DELETE)
	if $PopupMenu.item_count == 0:
		queue_free()


func _on_popup_menu_id_pressed(id):
	match id:
		CMD_NEW:
			pass
		CMD_RENAME:
			pass
		CMD_DELETE:
			pass


func _on_item_manage_dropdown_pressed():
	$PopupMenu.popup()
	$PopupMenu.position = self.global_position + Vector2(0, size.y)
