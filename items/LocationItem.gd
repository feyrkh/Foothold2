extends GameItem
class_name LocationItem

signal room_size_updated(room_size, occupied_room_size)

const KEY_ROOM_SIZE = 'Lrs'

var room_size = 1
var occupied_room_size = 0

func get_room_size():
	return room_size

func get_occupied_room_size():
	return occupied_room_size

func _ready():
	super._ready()
	contents_updated.connect(on_contents_updated)

func on_contents_updated():
	occupied_room_size = 0
	var furniture = find_child_items(func(item): return item.has_method('get_furniture_size'))
	for item in furniture:
		occupied_room_size += item.get_furniture_size()
	room_size_updated.emit(room_size, occupied_room_size)
	

func get_action_panel_scene_path()->String:
	return "res://items/FlexibleItemActions.tscn"

const ACTION_SECTIONS = ['Description']
func get_action_sections()->Array:
	return ACTION_SECTIONS

const SELF_TAGS = {Tags.TAG_LOCATION:true}
const ALLOWED_TAGS = {Tags.TAG_PC:true, Tags.TAG_EQUIPMENT:true, Tags.TAG_FURNITURE:true}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS

func finish_resolve_item_result(args):
	room_size = args.get(KEY_ROOM_SIZE, 1)

func can_accept_multi_drop(dropped_item_list:Array)->bool:
	var furniture_size = 0
	for dropped_item in dropped_item_list:
		var dropped_node = dropped_item.get_metadata(0)
		var closest_parent = dropped_node.get_closest_nonfolder_parent()
		if closest_parent == self:
			continue # don't count furniture size if the furniture is already in the room
		if dropped_node.has_method('get_furniture_size'):
			furniture_size += dropped_node.get_furniture_size()
	if occupied_room_size + furniture_size > room_size:
		Events.drag_error_msg.emit("%s is too full to accept this - clear %d space to make this fit" % [get_label(), -(room_size - occupied_room_size - furniture_size)])
		return false
	return super.can_accept_multi_drop(dropped_item_list)
