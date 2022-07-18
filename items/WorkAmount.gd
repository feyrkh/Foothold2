extends RefCounted
class_name WorkAmount

var work_type:String
var label:String
var effort:float
var bonus:float
var effort_modifiers:Array[String]

func _init(work_type:String, effort:float, bonus:float, effort_modifiers:Array[String]):
	self.work_type = work_type
	self.label = WorkTypes.name(work_type)
	self.effort = effort
	self.bonus = bonus
	self.effort_modifiers = effort_modifiers

func get_effort():
	return effort * (1+bonus)

func sort(a:WorkAmount, b:WorkAmount):
	return a.label < b.label
	
func add(amt:WorkAmount):
	if work_type != amt.work_type:
		push_error('Tried to add ', amt.work_type, ' WorkAmount to an existing WorkAmount of type ', work_type)
		return
	effort = amt.effort
	bonus = amt.bonus
	if amt.effort != 0:
		effort_modifiers.append("%s: +%.1f" % [WorkTypes.name(work_type), amt.effort])
	if amt.bonus != 0:
		effort_modifiers.append("%s: *%.2f" % [WorkTypes.name(work_type+WorkTypes.BONUS_SUFFIX), amt.bonus*100])
