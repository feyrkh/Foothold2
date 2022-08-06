extends GameItem

const SELF_TAGS = {}
const ALLOWED_TAGS = {Tags.TAG_VIS_SUPPLIER:true}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS

