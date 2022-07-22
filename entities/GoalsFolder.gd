extends GameItem

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
