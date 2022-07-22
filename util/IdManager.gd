extends Node

var next_id = 0
var id_map = {}

func get_next_id(item):
	next_id = next_id + 1
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
