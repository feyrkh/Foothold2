extends GameItemActions

@onready var SaveLoadContainer = find_child('SaveLoadContainer')

func _ready():
	find_child('NewSaveButton').connect('pressed', new_save)
	find_child('SaveLoadContainer').save_games_modified.connect(refresh_action_panel)
	refresh_action_panel()

func refresh_action_panel():
	get_game_item().refresh_save_files()
	find_child('SaveFileLabel').text = 'Save #' + SaveLoad.find_next_save_slot().trim_suffix('.sav')
	var save_files:Array[Dictionary] = get_game_item().save_files.values()
	save_files.sort_custom(func(a, b): return a.get(SaveLoad.KEY_SAVE_TIME) > b.get(SaveLoad.KEY_SAVE_TIME))
	SaveLoadContainer.clear_save_files()
	for save_file_info in save_files:
		SaveLoadContainer.add_save_file(save_file_info)
	super.refresh_action_panel()

func new_save():
	var label = find_child('SaveFileLabel').text.lstrip(' \n\t').rstrip(' \n\t')
	var filename = SaveLoad.find_next_save_slot()
	if label == '':
		label = filename.trim_suffix('.sav')
	Events.trigger_save_game.emit(label, SaveLoad.SAVE_DIR+filename)
	refresh_action_panel()
