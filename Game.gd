extends Control

@onready var ui:GameUI = find_child('GameUI')

func _ready():
	Events.connect('add_game_item', add_game_item)
	new_game()

func add_game_item(new_item, parent_item, select_item=false):
	var parent_tree_item
	if parent_item == null:
		parent_tree_item = null
	else:
		parent_tree_item = parent_item.tree_item
	ui.ItemTree.add_item(new_item, parent_tree_item)
	if select_item:
		ui.ItemTree.scroll_to_item(new_item.tree_item)
		new_item.tree_item.select(0)
		ui.ItemTree.emit_signal('multi_selected', new_item.tree_item, 0, true)

func new_game():
	var wizardTower:AreaItem = load('res://entities/wizard_tower/WizardTower.gd').new("Ancient tower")
	wizardTower.owner_lock_id = 'wiztower'
	wizardTower.explore_difficulty = 15
	ui.ItemTree.add_item(wizardTower)
	var pc:PcItem = PcItem.new('A wanderer')
	Events.emit_signal('add_game_item', pc, null, false)
