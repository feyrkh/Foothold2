extends MarginContainer
class_name ActionContainer

var contents:Node

func set_contents(contents):
	find_child('InnerContainer').add_child(contents)
	contents.connect('tree_exiting', queue_free)

func on_node_deleted(node:TreeNode):
	queue_free()

func _can_drop_data(at_position, data):
	if contents and is_instance_valid(contents):
		return contents._can_drop_data(at_position, data)

func _drop_data(at_position, data):
	if contents and is_instance_valid(contents):
		contents._drop_data(at_position, data)

func _get_drag_data(at_position):
	if contents and is_instance_valid(contents) and contents.has_method('get_game_item'):
		var item = contents.get_game_item().tree_item
		var drag_preview = Control.new()
		var label := Label.new()
		label.text = item.get_text(0)
		label.modulate = ReorderTree.DRAG_COLOR
		drag_preview.add_child(label)
			#print('item_region: ', get_item_area_rect(item))
		set_drag_preview(drag_preview)
		return [item]

