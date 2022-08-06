extends GameItem
class_name GoalItem

func _ready():
	super._ready()
	Events.connect('goal_progress', __on_goal_progress)
	Events.goal_callback.connect(__on_goal_callback)

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

func __on_goal_callback(goal_id, callback_fn, args=null):
	if goal_id == self.get_id():
		if has_method(callback_fn):
			call(callback_fn, args)
		else:
			push_error("Tried to trigger goal callback for nonexistent callback_fn='%s'; goal='%s'" % [callback_fn, self.label])
