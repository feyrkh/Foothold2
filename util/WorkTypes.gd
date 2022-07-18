extends Object
class_name WorkTypes

const BONUS_SUFFIX = '*'
const EXPLORE = 'e'

const NAMES = {
	EXPLORE: 'explore+',
	EXPLORE+BONUS_SUFFIX: 'explore*',
}

static func name(work_type):
	return NAMES.get(work_type, work_type)
