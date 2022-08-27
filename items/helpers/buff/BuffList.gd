extends RefCounted
class_name BuffList

var recipient_id
var __add_buffs_by_stat = {}
var __mult_buffs_by_stat = {}
var __buffs = []

func _to_config():
	var serialized_buffs = __buffs.map(func(entry): return Config.to_config(entry))
	return {'b':serialized_buffs, 'r':recipient_id}

func _from_config(c):
	Events.post_load_game.connect(post_load_game, ConnectFlags.CONNECT_ONESHOT)
	recipient_id = c['r']
	for buff_config in c['b']:
		var buff = Buff.new()
		Config.config(buff, buff_config)
		__buffs.append(buff)

func post_load_game():
	for buff in __buffs:
		index_buff(buff, recipient_id)
	var recipient = IdManager.get_item_by_id(recipient_id)
	if recipient != null:
		recipient.refresh_action_panel()

func add_buff(buff:Buff, recipient_id):
	if self.recipient_id != null and self.recipient_id != recipient_id:
		push_error('recipient_id in BuffList changed from ', self.recipient_id, ' to ', recipient_id)
	self.recipient_id = recipient_id
	__buffs.append(buff)
	index_buff(buff, recipient_id)

func get_add_bonus(stat):
	var result = 0
	for buff in __add_buffs_by_stat.get(stat, []):
		result += buff.get_add_buff(stat)
	return result

func get_multiply_bonus(stat):
	var result = 1.0
	for buff in __mult_buffs_by_stat.get(stat, []):
		result *= buff.get_multiply_buff(stat)
	return result

func remove_buff(buff:Buff):
	__buffs.erase(buff)
	if buff.add_effects != null:
		for stat_name in buff.add_effects:
			__add_buffs_by_stat.get(stat_name, []).erase(buff)
			if __add_buffs_by_stat.get(stat_name, []).is_empty():
				__add_buffs_by_stat.erase(stat_name)
	if buff.mult_effects != null:
		for stat_name in buff.mult_effects:
			__mult_buffs_by_stat.get(stat_name, []).erase(buff)
			if __mult_buffs_by_stat.get(stat_name, []).is_empty():
				__mult_buffs_by_stat.erase(stat_name)

func remove_buff_by_id(buff_id):
	for buff in __buffs:
		if buff.buff_id == buff_id:
			remove_buff(buff)
			return

func index_buff(buff:Buff, recipient_id):
	buff.setup(recipient_id)
	buff.buff_expired.connect(remove_buff)
	if buff.add_effects != null:
		for stat_name in buff.add_effects:
			if !__add_buffs_by_stat.has(stat_name):
				__add_buffs_by_stat[stat_name] = []
			__add_buffs_by_stat[stat_name].append(buff)
	if buff.mult_effects != null:
		for stat_name in buff.mult_effects:
			if !__mult_buffs_by_stat.has(stat_name):
				__mult_buffs_by_stat[stat_name] = []
			__mult_buffs_by_stat[stat_name].append(buff)
		
