extends GameItem
class_name GoalItem

func _ready():
	super._ready()
	Events.connect('goal_progress', __on_goal_progress)

const SELF_TAGS = {}
const ALLOWED_TAGS = {Tags.TAG_GOAL:true}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS

func on_goal_progress(data):
	pass # override for specific goals

func __on_goal_progress(goal_id, data):
	if goal_id == self.get_id():
		on_goal_progress(data)
