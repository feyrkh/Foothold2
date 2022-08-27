extends Object
class_name Tags

const TAG_FOLDER := '/'
const TAG_AREA := 'a'
const TAG_COMBAT_MANUAL := 'cm'
const TAG_COMBAT_STYLE := 'cs'
const TAG_EQUIPMENT := 'e'
const TAG_ENEMY := 'E'
const TAG_FURNITURE := 'f'
const TAG_GOAL := 'g'
const TAG_LOCATION := 'l'
const TAG_PC := 'p'
const TAG_VIS_SUPPLIER := 'v'
const TAG_WORK := 'w'

const TAG_NAMES = {
	TAG_FOLDER: 'folder',
	TAG_AREA: 'area',
	TAG_COMBAT_MANUAL: 'combat manual',
	TAG_COMBAT_STYLE: 'combat style',
	TAG_EQUIPMENT: 'equipment',
	TAG_ENEMY: 'enemy',
	TAG_FURNITURE: 'furniture',
	TAG_GOAL: 'goal',
	TAG_LOCATION: 'location',
	TAG_PC: 'character',
	TAG_VIS_SUPPLIER: 'vis supplier',
	TAG_WORK: 'work party',
}

static func tag_name(tag_id:String)->String:
	return TAG_NAMES.get(tag_id, tag_id)

const WORK_PARTY_EXPLORE := 'we'
const WORK_PARTY_MANUAL_LABOR := 'wl'
const WORK_PARTY_DESIGN_COMBAT_STYLE := 'dc'

