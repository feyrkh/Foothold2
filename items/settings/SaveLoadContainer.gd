extends VBoxContainer

signal save_games_modified()

func clear_save_files():
	for child in get_children():
		child.queue_free()

func add_save_file(save_file_info:Dictionary):
	var entry = load('res://items/settings/SaveLoadButtons.tscn').instantiate()
	add_child(entry)
	entry.setup(save_file_info)
	entry.save_games_modified.connect(on_save_games_modified)

func on_save_games_modified():
	save_games_modified.emit()
	
