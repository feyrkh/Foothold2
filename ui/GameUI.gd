extends PanelContainer
class_name GameUI

@onready var ItemTree:ReorderTree = find_child('ItemTree')
@onready var ActionContainer = find_child('ActionContainer')

var action_panels = {}

func _on_item_tree_selected_nodes_changed(selected_nodes, pinned_nodes):
	for node in action_panels:
		if !node or !is_instance_valid(node):
			action_panels.erase(node)
			continue
		if !selected_nodes.has(node) and !pinned_nodes.has(node):
			if is_instance_valid(action_panels[node]): 
				action_panels[node].queue_free()
			action_panels.erase(node)
	var all_nodes = []
	all_nodes.append_array(selected_nodes)
	all_nodes.append_array(pinned_nodes)
	var processed = {}
	for node in all_nodes:
		if processed.get(node):
			continue
		processed[node] = true
		if !action_panels.has(node):
			if node.has_method('build_action_panel'):
				var panel = node.build_action_panel(self)
				action_panels[node] = panel
				var container = preload("res://ui/ActionContainer.tscn").instantiate()
				container.set_contents(panel)
				ActionContainer.add_child(container)
				node.connect('deleting_node', container.on_node_deleted)
		
func _can_drop_data(at_position, data):
	return true

func new_folder(new_name, tree_node):
	Factory.place_item(Factory.folder(new_name), tree_node.tree_item)
