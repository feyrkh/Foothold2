extends HBoxContainer

signal save_games_modified()

var save_game_info

func setup(info):
	save_game_info = info
	$Label.text = info.get(SaveLoad.KEY_SAVE_LABEL, '<invalid save file>')
	$Label.hint_tooltip = info.get(SaveLoad.KEY_SAVE_TIME, '<invalid save file>')
	$LoadButton.connect('pressed', load_game)
	$OverwriteButton.connect('pressed', overwrite_game)
	$DeleteButton.connect('pressed', delete_game)

func load_game():
	Events.trigger_load_game.emit(save_game_info.get(SaveLoad.KEY_FILE_NAME))

func overwrite_game():
	Events.emit_signal('trigger_save_game', save_game_info.get(SaveLoad.KEY_SAVE_LABEL), save_game_info.get(SaveLoad.KEY_FILE_NAME))
	save_games_modified.emit()
	
func delete_game():
	var save_dir := SaveLoad.get_save_dir()
	var save_file = save_game_info.get(SaveLoad.KEY_FILE_NAME)
	var err = save_dir.remove(save_file)
	if err:
		push_error('Failed to delete save file '+save_file+': ', err)
	save_games_modified.emit()
