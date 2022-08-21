extends WorkAwareItem
class_name PcItem

signal status_updated()

const TASK_MEDITATE = 'M'
const TASK_REST = 'R'

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
			emit_signal('status_updated')
var focus=1000:
	get:
		return max(0, min(focus, get_max_focus()))
	set(val):
		if focus != val:
			focus = max(0, min(val, get_max_focus()))
			emit_signal('status_updated')

var active_work_task_id
var active_work_task_owner_id
var active_work_task_paused

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
	Events.game_tick.connect(regen_status)

func get_work_task_options(requestor:GameItem) -> Dictionary:
	var result = {}
	result[TASK_MEDITATE] = WorkTaskOption.build(TASK_MEDITATE, "Meditate", get_id(), "Recover your focus.", WorkTask.LOCATION_SELF)
	result[TASK_REST] = WorkTaskOption.build(TASK_REST, "Rest", get_id(), "Recover your health and stamina.", WorkTask.LOCATION_SELF)
	return self.work_task_list.filter_task_options(result, requestor)

func regen_status():
	if focus < get_max_focus():
		focus += get_focus_regen()
	if hp < get_max_hp():
		hp += get_hp_regen()

func get_action_panel_scene_path()->String:
	return "res://items/FlexibleItemActions.tscn"

const ACTION_SECTIONS = ['Description', 'Separator', 'PcStatus', 'Stats', 'WorkProvided', 'Separator', 'WorkTask']
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
	return 1.0 / 60

func get_max_hp():
	return stats[Stats.CONSTITUTION].get_stat_value() * 0.5

func get_hp_regen():
	return 1.0 / 3600

func get_stats():
	return stats

func derive_manual_labor_work(effort:float, bonus:float)->float:
	# manual labor is 
	return bonus * (effort + stats[Stats.CONSTITUTION].get_stat_value() * 0.0075 + stats[Stats.STRENGTH].get_stat_value() * 0.0025)

func derive_concentration_work(effort:float, bonus:float)->float:
	# manual labor is 
	return max(get_focus_regen(), min(focus, bonus * (effort + stats[Stats.WILLPOWER].get_stat_value() * 0.0075 + stats[Stats.INTELLIGENCE].get_stat_value() * 0.0025)))

func on_effort_applied(work_type:String, applied:float):
	if work_type == WorkTypes.CONCENTRATION:
		focus -= applied

func get_active_work_task_id():
	return active_work_task_id

func set_active_work_task_id(val):
	active_work_task_id = val

func get_active_work_task_owner_id():
	return active_work_task_owner_id

func set_active_work_task_owner_id(val):
	active_work_task_owner_id = val

func get_active_work_task_paused()->bool:
	return active_work_task_paused

func set_active_work_task_paused(val:bool):
	active_work_task_paused = val
