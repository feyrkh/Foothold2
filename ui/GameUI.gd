extends PanelContainer
class_name GameUI

@onready var ItemTree = find_child('ItemTree')
@onready var ActionContainer = find_child('ActionContainer')

var action_panels = {}

func _on_item_tree_selected_nodes_changed(selected_nodes):
	for node in action_panels:
		if !(selected_nodes.has(node)):
			action_panels[node].queue_free()
			action_panels.erase(node)
	for node in selected_nodes:
		if !action_panels.has(node):
			if node.has_method('build_action_panel'):
				var panel = node.build_action_panel(self)
				action_panels[node] = panel
				ActionContainer.add_child(panel)
		
