extends Object
class_name Stats

const STRENGTH := 0
const AGILITY := 1
const INTELLIGENCE := 2
const WILLPOWER := 3
const WISDOM := 4
const CONSTITUTION := 5
const PERCEPTION := 6
const STAT_COUNT := 7
const ALL_STATS = [STRENGTH, CONSTITUTION, AGILITY, WILLPOWER, WISDOM, PERCEPTION, INTELLIGENCE]

static func get_stat_name(stat_type)->String:
	match stat_type:
		STRENGTH: return "strength"
		AGILITY: return "agility"
		INTELLIGENCE: return "intelligence"
		WILLPOWER: return "willpower"
		WISDOM: return "wisdom"
		CONSTITUTION: return "constitution"
		PERCEPTION: return "perception"
		_: 
			push_error("unexpected stat ID in get_stat_name: ", stat_type)
			return "unknown"
