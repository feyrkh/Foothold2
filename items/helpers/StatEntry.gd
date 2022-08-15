extends RefCounted
class_name StatEntry

signal stat_total_updated(stat_entry, old_total, new_total)

# Stat layers:
# total_stat = ((((base + bonus) * toughened) + hardened) * empower
var stat_type := Stats.STRENGTH
var base := 100.0
var bonus := 0.0
var toughen := 1.0
var harden := 0.0
var empower := 1.0
var total := 100.0
var buff_providing_ids = {}

func _to_config():
	return [stat_type, base, toughen, harden, empower, buff_providing_ids]

static func new_stat(stat_type, base_value):
	var result = StatEntry.new()
	result.stat_type = stat_type
	result.base = base_value
	result.recalc_total()
	return result

static func from_config(c):
	var result = StatEntry.new()
	result.stat_type = c[0]
	result.base = c[1]
	result.toughen = c[2]
	result.harden = c[3]
	result.empower = c[4]
	result.buff_providing_ids = c[5]
	result.recalc_total()
	return result

func refresh():
	toughen = 1.0
	harden = 0.0
	empower = 1.0
	for id in buff_providing_ids.keys():
		var game_item = IdManager.get_item_by_id(id)
		if game_item == null:
			buff_providing_ids.erase(id)
			continue
		if game_item.has_method('get_base_stat_bonus'):
			bonus += game_item.get_base_stat_bonus(stat_type)
		if game_item.has_method('get_toughen_stat_bonus'):
			toughen += game_item.get_toughen_stat_bonus(stat_type)
		if game_item.has_method('get_harden_stat_bonus'):
			harden += game_item.get_harden_stat_bonus(stat_type)
		if game_item.has_method('get_empower_stat_bonus'):
			empower += game_item.get_empower_stat_bonus(stat_type)
	recalc_total()

func recalc_total():
	var old_total = total
	total = (((base+bonus) * toughen) + harden) * empower
	if old_total != total:
		stat_total_updated.emit(self, old_total, total)

func get_stat_value():
	return total
