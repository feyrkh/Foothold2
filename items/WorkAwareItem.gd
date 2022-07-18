extends GameItem
class_name WorkAwareItem

var inherent_work_types:Dictionary = {}
var work_types:Dictionary = {}

func _ready():
	connect('contents_updated', update_work_types)
	connect('parent_updated', _parent_updated)
	update_work_types()

func _parent_updated(old_parent, new_parent):
	update_work_types()

func update_work_types():
	var work_providing_items = find_child_items(func(game_item): return game_item.has_method('get_work_amounts'))
	var found_work_types = {}
	for k in inherent_work_types:
		found_work_types[k] = get_work_amount(k)
	for equip in work_providing_items:
		var equip_work_amounts = equip.get_work_amounts()
		for k in equip_work_amounts:
			var added_work_amount = equip_work_amounts[k]
			if !found_work_types.has(k):
				found_work_types[k] = added_work_amount
			else:
				found_work_types[k].add(added_work_amount)
	work_types = found_work_types

func get_work_helpers():
	return find_child_items(_is_work_helper) # By default, anything in a WorkAwareItem's inventory that has a get_work_amount method can help

func _is_work_helper(game_item) -> bool:
	return game_item.has_method('get_work_amount')

func get_work_amounts() -> Dictionary: # string->WorkAmount
	return work_types
	
func get_work_amount(work_type:String) -> WorkAmount:
	return work_types.get(work_type, null)

func get_work_amount_from_helpers(work_type:String, helpers:Array[GameItem]) -> WorkAmount:
	var effort:float = inherent_work_types.get(work_type, 0)
	var bonus:float = inherent_work_types.get(work_type+WorkTypes.BONUS_SUFFIX, 0)
	var effort_modifiers:Array[String] = []
	_added_effort(effort_modifiers, work_type, effort, bonus)
	for helper in helpers:
		var added_effort = helper.get_work_amount(work_type)
		var multiplied_effort = helper.get_work_amount(work_type+WorkTypes.BONUS_SUFFIX)
		effort += added_effort
		bonus += multiplied_effort
		_added_effort(effort_modifiers, work_type, added_effort, multiplied_effort)
	return WorkAmount.new(work_type, effort, bonus, effort_modifiers)
	
func _added_effort(effort_modifiers:Array[String], work_type:String, added_effort:float, multiplied_effort:float) -> void:
	if added_effort != 0:
		effort_modifiers.append("%s: +%.1f" % [WorkTypes.name(work_type), added_effort])
	if multiplied_effort != 1.0:
		effort_modifiers.append("%s: *%.2f" % [WorkTypes.name(work_type+WorkTypes.BONUS_SUFFIX), multiplied_effort*100])
