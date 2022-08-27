extends Object
class_name WorkTypes

const CONCENTRATION = 'c'
const CONTINUOUS = 'C'
const EXPLORE = 'e'
const MANUAL_LABOR = 'l'

const NAMES = {
	CONCENTRATION: 'concentration',
	CONTINUOUS: '(continuous)',
	EXPLORE: 'explore',
	MANUAL_LABOR: 'manual labor',
}

const TOOLTIP_DESCS = {
	CONCENTRATION: 'Applied mental focus. Focus stat determines how much can be applied at once.\nCan be drained with constant use.',
	CONTINUOUS: 'This task only stops when stopped manually, or when it is no longer possible to continue.',
	EXPLORE: "Following trails, uncovering hidden areas, quickly and safely.",
	MANUAL_LABOR: "Moving heavy objects, repetitive work, and other unskilled physical labor.",
}

static func name(work_type):
	return NAMES.get(work_type, work_type)

static func tooltip_desc(work_type):
	return TOOLTIP_DESCS.get(work_type, '')
