extends WorkAwareItem
class_name PcItem

signal status_updated() # hp/focus/etc updates
signal stats_updated() # str/dex/con/etc updates

const TASK_MEDITATE = 'M'
const TASK_REST = 'R'

const BUFF_FOCUS_REGEN = 'focus regen'
const BUFF_HP_REGEN = 'hp regen'

var stats:Array = []:
	set(val):
		# transform from serialized version
		for i in range(val.size()):
			if val[i] is Array:
				val[i] = StatEntry.from_config(val[i])
		stats = val

var hp=1000:
	get:
		return max(0, min(hp, get_max_hp()))
	set(val):
		if hp != val:
			hp = max(0, min(val, get_max_hp()))
			if val <= 0: set_is_tired(true)
			elif val >= get_max_hp(): check_tiredness_recovery()
			emit_signal('status_updated')
var focus=1000:
	get:
		return max(0, min(focus, get_max_focus()))
	set(val):
		if focus != val:
			focus = max(0, min(val, get_max_focus()))
			if val <= 0: set_is_tired(true)
			elif val >= get_max_focus(): check_tiredness_recovery()
			emit_signal('status_updated')

var buff_list:BuffList = BuffList.new()
var is_tired:bool = false

func check_tiredness_recovery():
	if is_tired and hp >= get_max_hp() and focus >= get_max_focus():
		set_is_tired(false)

func get_is_tired():
	return is_tired

func set_is_tired(val):
	if val == is_tired: 
		return
	print('Setting is_tired: ', val)
	is_tired = val
	if is_tired:
		self.set_label_suffix('_trd', '[tired]')
		self.set_label_suffix('work', null)
	else:
		self.set_label_suffix('_trd', null)
	update_work_amounts()

func get_work_amounts() -> Dictionary: # string->WorkAmount
	if get_is_tired():
		return {}
	return super.get_work_amounts()
	
func get_work_amount(work_type:String) -> WorkAmount:
	if get_is_tired():
		return null
	return super.get_work_amount(work_type)
	
func add_buff(buff:Buff):
	buff_list.add_buff(buff, get_id())
	status_updated.emit()
	stats_updated.emit()

func remove_buff(buff:Buff):
	buff_list.remove_buff(buff)
	status_updated.emit()
	stats_updated.emit()

func remove_buff_by_id(buff_id):
	buff_list.remove_buff_by_id(buff_id)
	status_updated.emit()
	stats_updated.emit()

func _init():
	super._init()
	inherent_work_amounts = {
		WorkTypes.EXPLORE: WorkAmount.new(WorkTypes.EXPLORE, 1.0, 0, {}, null, null),
		WorkTypes.MANUAL_LABOR: WorkAmount.new(WorkTypes.MANUAL_LABOR, 0.0, 0, {}, self.get_id(), 'derive_manual_labor_work'),
		WorkTypes.CONCENTRATION: WorkAmount.new(WorkTypes.CONCENTRATION, 0.0, 0, {}, self.get_id(), 'derive_concentration_work'),
	}
	stats = []
	for i in range(Stats.STAT_COUNT):
		stats.append(StatEntry.new_stat(i, 80 + (randi() % 41)))
	focus = get_max_focus()

func post_config(c):
	super.post_config(c)
#	for i in range(stats.size()):
#		stats[i] = StatEntry.from_config(stats[i])

func _ready():
	super._ready()
	check_tiredness_recovery()
	Events.game_tick.connect(regen_status)

func get_work_task_options(requestor:GameItem) -> Dictionary:
	var result = {}
	result[TASK_MEDITATE] = WorkTaskOption.build(TASK_MEDITATE, "Meditate", get_id(), "Recover your focus.", WorkTask.LOCATION_SELF)
	result[TASK_REST] = WorkTaskOption.build(TASK_REST, "Rest", get_id(), "Recover your health and stamina.", WorkTask.LOCATION_SELF)
	return self.work_task_list.filter_task_options(result, requestor)

func build_work_task(next_task:WorkTaskOption, contributor:GameItem) -> WorkTask:
	match next_task.get_id():
		TASK_MEDITATE: return build_meditate_task()
		TASK_REST: return build_rest_task()
		_: return null

func build_meditate_task() -> WorkTask:
	var work = WorkTask.new()
	work.set_description("Sit comfortably, close your eyes, and reflect on your inner being.", "")
	work.set_work_needed({WorkTypes.CONTINUOUS: 1})
	var meditate_buff = Buff.build_buff('meditate', get_id(), 0, true)
	meditate_buff.mult_effect(BUFF_FOCUS_REGEN, 3.0)
	var result:WorkResult = WorkResult.new()
	result.buff_while_working_result(meditate_buff)
	work.set_work_result(result)
	return work

func build_rest_task() -> WorkTask:
	var work = WorkTask.new()
	work.set_description("Perform minor first aid, relax, don't strain yourself.", "")
	work.set_work_needed({WorkTypes.CONTINUOUS: 999})
	var meditate_buff = Buff.build_buff('meditate', get_id(), 0, true)
	meditate_buff.mult_effect(BUFF_HP_REGEN, 3.0)
	var result:WorkResult = WorkResult.new()
	result.buff_while_working_result(meditate_buff)
	work.set_work_result(result)
	return work
	

func regen_status():
	if focus < get_max_focus():
		focus += get_focus_regen()
	if hp < get_max_hp():
		hp += get_hp_regen()

func get_action_panel_scene_path()->String:
	return "res://items/FlexibleItemActions.tscn"

const ACTION_SECTIONS = ['Description', 'Separator', 'WorkContributor', 'Separator', 'PcStatus', 'Stats', 'WorkProvided']
func get_action_sections()->Array:
	return ACTION_SECTIONS

const SELF_TAGS = {Tags.TAG_PC:true}
const ALLOWED_TAGS = {Tags.TAG_EQUIPMENT:true}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS
	
func get_description():
	return "A cool guy."

func get_furniture_size():
	return 1

func get_max_focus():
	return stats[Stats.WILLPOWER].get_stat_value() * 0.075 + stats[Stats.INTELLIGENCE].get_stat_value() * 0.025

func get_focus_regen():
	return (1.0 / 6) * buff_list.get_multiply_bonus(BUFF_FOCUS_REGEN) + buff_list.get_add_bonus(BUFF_FOCUS_REGEN)

func get_max_hp():
	return stats[Stats.CONSTITUTION].get_stat_value() * 0.5

func get_hp_regen():
	return (1.0 / 3600) * buff_list.get_multiply_bonus(BUFF_HP_REGEN) + buff_list.get_add_bonus(BUFF_HP_REGEN)

func get_stats():
	return stats

func get_stat(stat_id)->StatEntry:
	if stat_id >= 0 and stat_id < stats.size():
		return stats[stat_id]
	push_error('Invalid stat_id in ', get_label(), ': ', stat_id)
	return null

func derive_manual_labor_work(effort:float, bonus:float)->float:
	# manual labor is 
	return bonus * (effort + stats[Stats.CONSTITUTION].get_stat_value() * 0.0075 + stats[Stats.STRENGTH].get_stat_value() * 0.0025)

func derive_concentration_work(effort:float, bonus:float)->float:
	# manual labor is 
	return max(get_focus_regen(), min(focus, bonus * (effort + stats[Stats.WILLPOWER].get_stat_value() * 0.0075 + stats[Stats.INTELLIGENCE].get_stat_value() * 0.0025)))

func on_effort_applied(work_type:String, applied:float):
	if work_type == WorkTypes.CONCENTRATION:
		focus -= applied
