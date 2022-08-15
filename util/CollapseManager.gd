extends Node

var id_map = {}

func _ready():
	Events.connect('pre_load_game', pre_load_game)
	Events.connect('pre_save_game', pre_save_game)
	Events.global_load_data.connect(global_load_data)

func pre_save_game():
	cleanup_dead_items()
	Events.global_save_data.emit('CollapseManager', Config.to_config(self))

func global_load_data(data_id, config):
	if data_id == 'CollapseManager':
		Config.config(self, config)
		print('CollapseManager reloaded, ', id_map.size(), ' collapse sections tracked')

func pre_load_game():
	id_map = {}

func cleanup_dead_items():
	for id in id_map.keys():
		var item = IdManager.get_item_by_id(id)
		if !item or !is_instance_valid(item):
			id_map.erase(id)

func set_collapsed(game_item_id, collapse_id, collapsed:bool):
	if collapse_id==null or collapse_id=='':
		return
	if !collapsed:
		delete_collapse_entry(game_item_id, collapse_id)
	else:
		add_collapse_entry(game_item_id, collapse_id)

const EMPTY_DICT = {}
func get_collapsed(game_item_id, collapse_id)->bool:
	return id_map.get(game_item_id, EMPTY_DICT).get(collapse_id, false)

func add_collapse_entry(game_item_id, collapse_id):
	var game_item_map
	if !id_map.has(game_item_id):
		game_item_map = {}
		id_map[game_item_id] = game_item_map
	else:
		game_item_map = id_map[game_item_id]
	game_item_map[collapse_id] = true

func delete_collapse_entry(game_item_id, collapse_id):
	var game_item_map = id_map.get(game_item_id)
	if game_item_map == null: return
	if !game_item_map.has(collapse_id): return
	game_item_map.erase(collapse_id)
	if game_item_map.size() == 0:
		id_map.erase(game_item_id)
