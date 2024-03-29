extends RefCounted
class_name WorkAmount

var work_type:String
var label:String
var effort:float
var bonus:float
var helper_ids_used:Dictionary
var derived_stat_owner_id # If set, call derived_stat_owner_function(effort, 1+bonus) and use that instead of the actual effort 
var derived_stat_owner_function

static func build_from_config(entry_conf:Dictionary) -> WorkAmount:
	return WorkAmount.new(entry_conf.get('work_type'), entry_conf.get('effort', 99999), entry_conf.get('bonus', 0), entry_conf.get('helper_ids_used', {}), entry_conf.get('derived_stat_owner_id', null), entry_conf.get('derived_stat_owner_function', null))
	
func _init(work_type:String, effort:float, bonus:float, helper_ids_used:Dictionary, derived_stat_owner_id=null, derived_stat_owner_function=null):
	self.work_type = work_type
	self.label = WorkTypes.name(work_type)
	self.effort = effort
	self.bonus = bonus
	self.helper_ids_used = helper_ids_used
	self.derived_stat_owner_id = derived_stat_owner_id
	self.derived_stat_owner_function = derived_stat_owner_function

func get_total_effort():
	if derived_stat_owner_id:
		var owner = IdManager.get_item_by_id(derived_stat_owner_id)
		if owner:
			return owner.call(derived_stat_owner_function, effort, 1+bonus)
	return effort * (1+bonus)

static func sort(a:WorkAmount, b:WorkAmount):
	return a.label < b.label


func add(amt:WorkAmount):
	if work_type != amt.work_type:
		push_error('Tried to add ', amt.work_type, ' WorkAmount to an existing WorkAmount of type ', work_type)
		return
	effort += amt.get_total_effort()
	if amt.effort != 0:
		helper_ids_used.merge(amt.helper_ids_used)

func apply_effort(amt:float):
	effort -= amt/(1+bonus)

func get_helpers_description() -> String:
	if helper_ids_used.is_empty():
		return ''
	var names = PackedStringArray(helper_ids_used.keys().map(func(helper_id): 
		var helper = IdManager.get_item_by_id(helper_id)
		if helper:
			return helper.label
	))
	return "Affected by: "+", ".join(names)

func on_effort_applied(work_type, applied):
	for helper_id in helper_ids_used:
		var helper = IdManager.get_item_by_id(helper_id)
		if helper and helper.has_method('on_effort_applied'):
			helper.on_effort_applied(work_type, applied)

static func copy(other:WorkAmount) -> WorkAmount:
	return WorkAmount.new(other.work_type, other.effort, other.bonus, other.helper_ids_used.duplicate(), other.derived_stat_owner_id, other.derived_stat_owner_function)
