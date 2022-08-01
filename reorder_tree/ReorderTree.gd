extends Tree
class_name ReorderTree

signal selected_nodes_changed(selected_nodes:Array[TreeNode], pinned_nodes:Array[TreeNode])

const DRAG_COLOR = Color(1.0, 1.0, 1.0, 0.5)

var pinned_nodes:Array[TreeNode] = []
var root:TreeItem

# Called when the node enters the scene tree for the first time.
func _ready():
	connect('multi_selected', on_multi_selected)
	Events.connect('pin_action_panel', set_panel_pinned)
	Events.connect('pre_load_game', clear)
	root = create_item()
#	if get_parent() == get_tree().root:
#		var item1 = add_item(GameItem.new('Wizard Tower'), root)
#		var item2 = add_item(GameItem.new('Stone chamber'), item1)
#		item2.get_metadata(0).owner_lock_id = 'chamber'
#		var item3 = add_item(GameItem.new('Rooftop'), item1)
#		var item4 = add_item(GameItem.new('rubbish'), item2)
#		item4.get_metadata(0).allowed_owner_lock_id = 'chamber'
#		var item5 = add_item(GameItem.new('rubbish'), item2)
#		item5.get_metadata(0).allowed_owner_lock_id = 'chamber'
#		var item6 = add_item(GameItem.new('rubbish'), item2)
#		item6.get_metadata(0).allowed_owner_lock_id = 'chamber'
#		for i in range(100):
#			var padding_item = add_item(FolderItem.new('padding #'+str(i)), root)

func clear():
	super.clear()
	root = create_item()

func save_data() -> Array:
	var data = []
	for tree_item in get_root().get_children():
		var save_data = save_data_for_item(tree_item)
		if save_data and save_data.size() > 0:
			data.append(save_data)
	return data

func load_data(data:Array, parent_tree_item:TreeItem=null):
	for tree_item_data in data:
		load_data_for_item(tree_item_data, parent_tree_item)

func save_data_for_item(tree_item:TreeItem) -> Array:
	var tree_node:TreeNode = tree_item.get_metadata(0)
	if tree_node and is_instance_valid(tree_node):
		if tree_node.has_method('skip_save') and tree_node.skip_save():
			return []
		if tree_item.get_child_count() > 0:
			var child_save_data = []
			for child_item in tree_item.get_children():
				var item_save_data = save_data_for_item(child_item)
				if item_save_data and item_save_data.size() > 0:
					child_save_data.append(item_save_data)
			return [tree_node.get_script().resource_path, Config.to_config(tree_node), child_save_data]
		else:
			return [tree_node.get_script().resource_path, Config.to_config(tree_node)]
	else:
		return []

func load_data_for_item(tree_item_data:Array, parent_tree_item:TreeItem):
	var script_path:String = tree_item_data[0]
	var script_config:Dictionary = tree_item_data[1]
	var tree_node = load(script_path).new()
	Config.config(tree_node, script_config)
	if tree_node.has_method('post_load_game'):
		tree_node.connect('post_load_game', tree_node.post_load_game, [], ConnectFlags.CONNECT_ONESHOT)
	if tree_node.has_method('finalize_load_game'):
		tree_node.connect('finalize_load_game', tree_node.finalize_load_game, [], ConnectFlags.CONNECT_ONESHOT)
	IdManager.register_id(tree_node.get_id(), tree_node)
	var new_tree_item = add_item(tree_node, parent_tree_item)
	IdManager.add_child(tree_node)
	if tree_item_data.size() >= 3:
		var child_save_data = tree_item_data[2]
		for child_entry in child_save_data:
			load_data_for_item(child_entry, new_tree_item)

func set_panel_pinned(tree_node:TreeNode, is_pinned:bool):
	if !tree_node or !is_instance_valid(tree_node):
		return
	if is_pinned and !pinned_nodes.has(tree_node):
		pinned_nodes.append(tree_node)
	elif !is_pinned and pinned_nodes.has(tree_node):
		pinned_nodes.erase(tree_node)
	emit_signal('selected_nodes_changed', get_selected_nodes(), pinned_nodes)

func add_item(tree_node:TreeNode, parent_item:TreeItem=null):
	if parent_item == null:
		parent_item = root
	var new_item = create_item(parent_item)
	new_item.set_metadata(0, tree_node)
	new_item.set_text(0, tree_node.get_label())
	tree_node.tree_item = new_item
	var parent_node = parent_item.get_metadata(0)
	if parent_node:
		parent_node.emit_signal('contents_updated')
	tree_node.connect('deleting_node', on_deleting_node)
	new_item.emit_signal('parent_updated', null, parent_node)
	return new_item

func on_deleting_node(node):
	pinned_nodes.erase(node)

func on_multi_selected(item:TreeItem, column:int, selected:bool):
	if selected and (Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CTRL)):
		var item_parent = item.get_parent()
		var cur_selected = get_next_selected(null)
		#while cur_selected != null:
		#	if cur_selected.get_parent() != item_parent:
		#		item.deselect(column)
		#		return
		#	cur_selected = get_next_selected(cur_selected)
	elif !selected:
		item.deselect(column)
	emit_signal('selected_nodes_changed', get_selected_nodes(), pinned_nodes)

func get_selected_items()->Array[TreeItem]:
	var result:Array[TreeItem] = []
	var cur_selected = get_next_selected(null)
	while cur_selected != null:
		result.append(cur_selected)
		cur_selected = get_next_selected(cur_selected)
	return result

func get_selected_nodes()->Array:
	var result:Array[TreeNode] = []
	var cur_selected = get_next_selected(null)
	while cur_selected != null:
		result.append(cur_selected.get_metadata(0))
		cur_selected = get_next_selected(cur_selected)
	return result

func _get_drag_data(position: Vector2):
	var selected := get_selected_items()
	if selected.size() == 0:
		return
	var drag_preview = Control.new()
	var start_pos = get_item_area_rect(selected[0]).position
	for item in selected:
		var label := Label.new()
		label.text = item.get_text(0)
		label.modulate = DRAG_COLOR
		drag_preview.add_child(label)
		label.position = get_item_area_rect(item).position - start_pos
		#print('item_region: ', get_item_area_rect(item))
	set_drag_preview(drag_preview)
	return selected

func check_valid_drop(target_item, dropped_item_list):	
	for dropped_item in dropped_item_list:
		var dropped_node = dropped_item.get_metadata(0)
		if !target_item.get_metadata(0).can_accept_drop(dropped_node):
			return false
	return true

func _can_drop_data(position, dropped_item_list):
	if !(dropped_item_list is Array):
		drop_mode_flags = DROP_MODE_DISABLED
		return false
	drop_mode_flags = DROP_MODE_INBETWEEN|DROP_MODE_ON_ITEM
	var offset = get_drop_section_at_position(position)
	var target_item = get_item_at_position(position)
	if offset == -100:
		# dropped at the bottom of the list, this can always work since it will move the item to the end of the list
		drop_mode_flags = DROP_MODE_INBETWEEN
		#print('offset -100')
		return false
	if target_item in dropped_item_list:
		drop_mode_flags = DROP_MODE_DISABLED
		return false
	if target_item.get_child_count() > 0 and !target_item.collapsed:
		offset = 0
	if offset == 0:
		# dropped on top of an item
		if !check_valid_drop(target_item, dropped_item_list):
			offset = -1
			drop_mode_flags = DROP_MODE_DISABLED
			#print('drop on top, but invalid drop')
			return false
		else:
			return true
	if offset != 0:
		if !check_valid_drop(target_item.get_parent(), dropped_item_list):
			drop_mode_flags = DROP_MODE_DISABLED
			#print('drop before/after, but invalid drop')
			return false
		else:
			drop_mode_flags = DROP_MODE_INBETWEEN
			#print('valid drop')
			return true

func _drop_data(position, dropped_item_list):
	var offset = get_drop_section_at_position(position)
	var target_item = get_item_at_position(position)
	drop_data_at_offset(target_item, offset, dropped_item_list)

func drop_data_at_offset(target_item, offset, dropped_item_list):
	if offset == -100:
		target_item = dropped_item_list[0].get_parent().get_child(-1)
		offset = 1
	if target_item.get_child_count() > 0 and !target_item.collapsed and offset > 0:
		if !check_valid_drop(target_item, dropped_item_list):
			return
		else:
			var placeholder = create_item()
			placeholder.move_before(target_item.get_first_child())
			perform_drop(placeholder, dropped_item_list, -1)
			placeholder.free()
			return
	if offset == 0:
		if !check_valid_drop(target_item, dropped_item_list):
			offset = -1
		else:
			perform_drop(target_item, dropped_item_list, 0)
			return
	if offset != 0:
		if !check_valid_drop(target_item.get_parent(), dropped_item_list):
			return
		else:
			perform_drop(target_item, dropped_item_list, offset)
			return

#dropped_item_list:Array[TreeItem]
func perform_drop(target_item:TreeItem, dropped_item_list, offset):
	var placeholder
	var item_set = {}
	for item in dropped_item_list:
		item_set[item] = true
	if offset == 0:
		if target_item.get_child_count() == 0:
			# no child, so we have to create one before we can move the dropped items to the end, and then remove it again
			placeholder = target_item.create_child()
		var last_child = target_item.get_child(target_item.get_child_count()-1)
		var new_parent = last_child.get_parent().get_metadata(0)
		for item in dropped_item_list:
			if !ancestor_is_moving(item, item_set):
				var previous_parent = item.get_parent().get_metadata(0)
				item.move_after(last_child)
				if previous_parent != new_parent:
					if previous_parent:
						previous_parent.emit_signal('contents_updated')
					if new_parent:
						new_parent.emit_signal('contents_updated')
					item.get_metadata(0).emit_signal('parent_updated', previous_parent, new_parent)
				last_child = item
	elif offset == 1:
		placeholder = target_item.get_parent().create_child()
		placeholder.move_after(target_item)
		var new_parent = placeholder.get_parent().get_metadata(0)
		for item in dropped_item_list:
			if !ancestor_is_moving(item, item_set):
				var previous_parent = item.get_parent().get_metadata(0)
				item.move_before(placeholder)
				if previous_parent:
					previous_parent.emit_signal('contents_updated')
				if new_parent:
					new_parent.emit_signal('contents_updated')
				item.get_metadata(0).emit_signal('parent_updated', previous_parent, new_parent)
	elif offset == -1:
		placeholder = target_item.get_parent().create_child()
		placeholder.move_before(target_item)
		var new_parent = placeholder.get_parent().get_metadata(0)
		for item in dropped_item_list:
			if !ancestor_is_moving(item, item_set):
				var previous_parent = item.get_parent().get_metadata(0)
				item.move_before(target_item)
				if previous_parent:
					previous_parent.emit_signal('contents_updated')
				if new_parent:
					new_parent.emit_signal('contents_updated')
				item.get_metadata(0).emit_signal('parent_updated', previous_parent, new_parent)
	if placeholder:
		placeholder.free()

func ancestor_is_moving(item, item_set):
	var p = item.get_parent()
	while p != null:
		if item_set.has(p):
			return true
		p = p.get_parent()
	return false
