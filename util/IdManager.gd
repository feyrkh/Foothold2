extends Node

var next_id = 0
var id_map = {}

func _ready():
	Events.connect('add_game_item', on_add_game_item)
	Events.connect('pre_load_game', pre_load_game)
	Events.connect('pre_save_game', pre_save_game)
	Events.global_load_data.connect(global_load_data)

func pre_save_game():
	cleanup_dead_items()
	Events.global_save_data.emit('IdManager', Config.to_config(self))

func global_load_data(data_id, config):
	if data_id == 'IdManager':
		Config.config(self, config)
		print('IdManager reloaded, next_id = ', next_id)

func pre_load_game():
	next_id = 0
	for child in get_children():
		child.queue_free()
	id_map = {}

func _to_config() -> Dictionary:
	return {'next_id': next_id} # don't save id_map

func on_add_game_item(game_item, game_item_parent, selected=false):
	if game_item and is_instance_valid(game_item):
		register_id(game_item.get_id(), game_item)

func get_next_id(item=null)->int:
	next_id = next_id + 1
	if item:
		register_id(next_id, item)
	return next_id

func register_id(id, item:GameItem):
	id_map[id] = item

func cleanup_dead_items():
	for k in id_map.keys():
		if !id_map[k] or !is_instance_valid(id_map[k]):
			id_map.erase(k)

func get_item_by_id(id) -> GameItem:
	if id == null:
		return null
	var result = id_map.get(id)
	if result and !is_instance_valid(result):
		id_map.erase(id)
		return null
	return result
