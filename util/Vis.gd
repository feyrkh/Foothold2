extends Object
class_name Vis

const KEY_TYPE:='vt'
const KEY_SIZE:='vs'
const KEY_AMOUNT:='va'
const KEY_MAX_AMOUNT:='vx'

const TYPE_IMPURE:=0

const VIS_TYPE_NAMES:={
	TYPE_IMPURE: 'impure'
}

static func vis_type_name(vis_type):
	return VIS_TYPE_NAMES.get(vis_type, 'unknown')
