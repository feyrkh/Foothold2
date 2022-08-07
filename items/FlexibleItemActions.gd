extends GameItemActions
class_name FlexibleItemActions

# Array of entries like any of these:
# 	Each of these resolve to  'res://ui/sections/DescriptionSection.tscn'
# 		'Description'
# 		'DescriptionSection'
# 		'DescriptionSection.tscn' 
# 	Entries starting with 'res://' and end with '.tscn' are taken as-is:
# 		res://Something.tscn' has no changes
# 	Entries ending with '.tscn' do not have anything added to their ends:
# 		'Something.tscn' -> 'res://ui/sections/Something.tscn'
# 	Entries not ending with '.tscn' and also not ending with 'Section' have 'Section.tscn' added:
# 		'Something' -> 'res://ui/sections/SomethingSection.tscn'
# 		'res://otherpath/Something' -> 'res://otherpath/SomethingSection.tscn'
# 	Entries ending in 'Section' but not '.tscn' have '.tscn' added:
# 		'SomethingSection' -> 'res://ui/sections/SomethingSection.tscn'
# 		'res://otherpath/SomethingSection' -> 'res://otherpath/SomethingSection.tscn' 
func set_action_sections(action_section_script_names:Array):
	for script_name in action_section_script_names:
		add_action_section(script_name)
	
func add_action_section(script_name):
	if !script_name.begins_with('res://'):
		script_name = 'res://ui/sections/'+script_name
	if !script_name.ends_with('.tscn') and !script_name.ends_with('Section') and !script_name.ends_with('Section.tscn'):
		script_name = script_name + 'Section.tscn'
	if !script_name.ends_with('.tscn'):
		script_name = script_name + '.tscn'
	var section = load(script_name).instantiate()
	add_child(section)

func setup_action_panel(game_ui:GameUI, game_item:GameItem):
	add_action_section('res://ui/sections/ItemActionHeader.tscn')
	super.setup_action_panel(game_ui, game_item)

func _ready():
	super._ready()
	create_action_sections(get_game_item())

func create_action_sections(game_item):
	if game_item.has_method('get_action_sections'):
		set_action_sections(game_item.get_action_sections())
	else:
		push_error('Tried to create_action_sections for ', game_item.get_label(), ' but it does not contain get_action_sections')
