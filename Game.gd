extends Control

@onready var ui:GameUI = find_child('GameUI')

var global_data = {}

func _ready():
	Events.connect('add_game_item', add_game_item)
	Events.connect('trigger_save_game', save_game)
	Events.connect('trigger_load_game', load_game)
	Events.connect('global_save_data', global_save_data)
	new_game()

func global_save_data(data_id, data_conf):
	global_data[data_id] = data_conf

func add_game_item(new_item, parent_item, select_item=false):
	var parent_tree_item
	if parent_item == null:
		parent_tree_item = null
	else:
		parent_tree_item = parent_item.tree_item
	ui.ItemTree.add_item(new_item, parent_tree_item)
	IdManager.add_child(new_item)
	if select_item:
		ui.ItemTree.scroll_to_item(new_item.tree_item)
		new_item.tree_item.select(0)
		ui.ItemTree.emit_signal('multi_selected', new_item.tree_item, 0, true)

func new_game():
	global_data = {}
	var settings = Factory.item('Settings', 'res://entities/SettingsFolder.gd')
	Factory.place_item(settings, null)
	var goals = Factory.item('Goals', 'res://entities/GoalsFolder.gd')
	Factory.place_item(goals, null)
	var tutorial = Factory.goal('res://goals/PortalTutorial.gd')
	tutorial.setup()

func save_game(save_label:String, save_file_path:String):
	global_data = {}
	Events.emit_signal("pre_save_game")
	var f := SaveLoad.start_save_file(save_label, save_file_path)
	var ui_save_data = ui.save_data()
	f.store_var(ui_save_data)
	f.store_var(global_data)
	f.close()
	print('UI data:\n', JSON.new().stringify(ui_save_data))
	print('Global data:\n', JSON.new().stringify(global_data))
	Events.emit_signal("post_save_game")
	return true

func load_game(save_file_path:String):
	Debug.orphans('start of load_game')
	get_tree().paused = false
	Events.emit_signal("pre_load_game")
	Debug.orphans('after pre_load_game')
	var save_info:Dictionary = SaveLoad.open_load_file(save_file_path)
	var f:File = save_info.get(SaveLoad.KEY_FILE, null)
	if !f:
		printerr(save_file_path, " : Failed to open save file while loading")
		return false
	var ui_save_data = f.get_var()
	global_data = f.get_var()
	f.close()
	Debug.orphans('after file read')
	ui.load_data(ui_save_data)
	Debug.orphans('after ui.load_data')
	for k in global_data:
		Events.global_load_data.emit(k, global_data[k])
	Debug.orphans('after global_load_data')
	await get_tree().process_frame
	Events.emit_signal("post_load_game")
	Debug.orphans('after post_load_game')
	await get_tree().process_frame
	Events.emit_signal("finalize_load_game")
	
	Debug.orphans('end of load_game')
	return true

func save_game_defaults():
	#save_game_default("grias_levelup_energy", [25, 25, 25, 0])
	pass

func save_game_default(game_state:Dictionary, k:String, default_val_if_missing):
	if game_state.has(k):
		return
	game_state[k] = default_val_if_missing
