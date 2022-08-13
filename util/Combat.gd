extends Object
class_name Combat

const PHYSICAL_ATTACK = 0
const PHYSICAL_DEFEND = 1
const IMPURE_VIS_ATTACK = 2
const IMPURE_VIS_DEFEND = 3 

static func is_attack(damage_type:int)->bool:
	return posmod(damage_type, 2) == 0

static func is_defend(damage_type:int) -> bool:
	return posmod(damage_type, 2) == 1
