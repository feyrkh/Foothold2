extends WorkProvidingItem
class_name WorkAwareItem

# finish_resolve_item_result args:
#   work_amounts: dictionary of WorkTypes -> float that's used for inherent_work_amounts

var inherent_work_amounts:Dictionary = {}
var work_amounts:Dictionary = {}

func post_config(config:Dictionary):
	if inherent_work_amounts != null:
		for k in inherent_work_amounts:
			var entry_conf = inherent_work_amounts[k]
			inherent_work_amounts[k] = WorkAmount.build_from_config(entry_conf)
	if work_amounts != null:
		for k in work_amounts:
			var entry_conf = work_amounts[k]
			work_amounts[k] = WorkAmount.build_from_config(entry_conf)
	
			
func _ready():
	super._ready()
	connect('contents_updated', update_work_amounts)
	connect('parent_updated', _parent_updated)
	update_work_amounts()

func finish_resolve_item_result(args):
	var amts = args.get('work_amounts', {})
	for k in amts:
		var amt = amts.get(k)
		if amt != null:
			inherent_work_amounts[k] = WorkAmount.new(k, amt, 0.0, {get_id():1}, null, null)
	update_work_amounts()

func _parent_updated(old_parent, new_parent):
	update_work_amounts()

func update_specific_work_amount(work_type):
	var work_providing_items = get_work_helpers()
	var work_amount = inherent_work_amounts.get(work_type, null)
	if work_amount != null:
		if work_amount is WorkAmount:
			work_amount = WorkAmount.copy(work_amount)
		else:
			# hopefully it's an integer
			work_amount = WorkAmount.new(work_type, work_amount, 0.0, {get_id():1}, null, null)
	for equip in work_providing_items:
		var equip_work_amounts = equip.get_work_amounts()
		var added_work_amount = equip_work_amounts.get(work_type)
		if added_work_amount:
			if !work_amount:
				work_amount = added_work_amount
			else:
				work_amount.add(added_work_amount)
	if work_amount == null:
		work_amounts.erase(work_type)
	else:
		work_amounts[work_type] = work_amount
	update_parent_work_amounts()
	refresh_action_panel()
	
func update_work_amounts():
	var work_providing_items = get_work_helpers()
	var found_work_amounts = {}
	for k in inherent_work_amounts:
		found_work_amounts[k] = WorkAmount.copy(inherent_work_amounts[k])
		found_work_amounts[k].helper_ids_used[get_id()] = 1
	for equip in work_providing_items:
		var equip_work_amounts = equip.get_work_amounts()
		for k in equip_work_amounts:
			var added_work_amount = equip_work_amounts[k]
			if !found_work_amounts.has(k):
				found_work_amounts[k] = added_work_amount
			else:
				found_work_amounts[k].add(added_work_amount)
			found_work_amounts[k].helper_ids_used[equip.get_id()] = 1
	work_amounts = found_work_amounts
	update_parent_work_amounts()
	refresh_action_panel()

func update_parent_work_amounts():
	var closest_parent = get_closest_nonfolder_parent()
	if closest_parent and closest_parent.has_method('update_work_amounts'):
		closest_parent.update_work_amounts()

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
