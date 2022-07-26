extends Object
class_name WorkTypes

const BONUS_SUFFIX = '*'
const EXPLORE = 'e'
const MANUAL_LABOR = 'l'

const NAMES = {
	EXPLORE: 'explore',
	EXPLORE+BONUS_SUFFIX: 'explore*',
	MANUAL_LABOR: 'manual labor',
	MANUAL_LABOR+BONUS_SUFFIX: 'manual labor*',
}

static func name(work_type):
	return NAMES.get(work_type, work_type)
