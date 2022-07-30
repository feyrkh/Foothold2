extends Node

var next_id = 0
var id_map = {}

func _ready():
	Events.connect('add_game_item', on_add_game_item)

func on_add_game_item(game_item, game_item_parent, selected=false):
	if game_item and is_instance_valid(game_item):
		register_id(game_item.get_id(), game_item)

func get_next_id(item=null)->int:
	next_id = next_id + 1
	if item:
		register_id(next_id, item)
	return next_id

func register_id(id, item):
	id_map[id] = item

func cleanup_dead_items():
	for k in id_map:
		if !id_map[k] or !is_instance_valid(id_map[k]):
			id_map.erase(k)

func get_item_by_id(id):
	var result = id_map.get(id)
	if result and !is_instance_valid(result):
		id_map.erase(id)
		return null
	return result
