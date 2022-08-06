extends GameItem
class_name GoalsFolder

var goals = {}

static func get_goal(goal_id):
	var mainLoop = Engine.get_main_loop();
	var sceneTree = mainLoop as SceneTree;
	var goal_folder:GoalsFolder = sceneTree.get_first_node_in_group('goals_folder')
	push_error('GoalsFolder.get_goal not implemented')
	return null

func _ready():
	super._ready()
	add_to_group('goals_folder', true)
	Events.connect('add_goal', on_add_goal)

func on_add_goal(goal):
	Events.emit_signal('add_game_item', goal, self)

func _contents_updated():
	pass

func can_delete():
	return false

func get_allowed_owner_lock_id():
	return 'n/a'

const SELF_TAGS = {}
const ALLOWED_TAGS = {Tags.TAG_GOAL:true}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS
