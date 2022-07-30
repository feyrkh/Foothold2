extends GameItem
class_name WorkAwareItem

# finish_resolve_item_result args:
#   work_amounts: dictionary of WorkTypes -> float that's used for inherent_work_amounts

var inherent_work_amounts:Dictionary = {}
var work_amounts:Dictionary = {}

func _ready():
	connect('contents_updated', update_work_amounts)
	connect('parent_updated', _parent_updated)
	update_work_amounts()

func finish_resolve_item_result(args):
	var amts = args.get('work_amounts', {})
	for k in amts:
		var amt = amts.get(k)
		if amt != null:
			inherent_work_amounts[k] = WorkAmount.new(k, amt, 0.0, [])
	update_work_amounts()

func _parent_updated(old_parent, new_parent):
	update_work_amounts()

func update_work_amounts():
	var work_providing_items = get_work_helpers()
	var found_work_amounts = {}
	for k in inherent_work_amounts:
		found_work_amounts[k] = WorkAmount.copy(inherent_work_amounts[k])
	for equip in work_providing_items:
		var equip_work_amounts = equip.get_work_amounts()
		for k in equip_work_amounts:
			var added_work_amount = equip_work_amounts[k]
			if !found_work_amounts.has(k):
				found_work_amounts[k] = added_work_amount
			else:
				found_work_amounts[k].add(added_work_amount)
	work_amounts = found_work_amounts
	refresh_action_panel()

func get_work_helpers():
	return find_child_items(_is_work_helper) # By default, anything in a WorkAwareItem's inventory that has a get_work_amount method can help

func _is_work_helper(game_item) -> bool:
	return game_item.has_method('get_work_amount')

func get_work_amounts() -> Dictionary: # string->WorkAmount
	if work_amounts.size() < inherent_work_amounts.size():
		update_work_amounts()
	return work_amounts
	
func get_work_amount(work_type:String) -> WorkAmount:
	return work_amounts.get(work_type, null)
	
func _added_effort(effort_modifiers:Array[String], work_type:String, added_effort:float) -> void:
	if added_effort != null and added_effort != 0:
		effort_modifiers.append("%s: +%.1f" % [WorkTypes.name(work_type), added_effort])
