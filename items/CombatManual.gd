extends WorkProvidingItem
class_name CombatManual

const TASK_PREFIX_BUILD_STYLE = 'bld$'
const TASK_PREFIX_STUDY_STYLE = 'std$'

# number of stances in the style
const KEY_STANCE_COUNT = 'CM1'
const KEY_STANCE_COUNT_VARIANCE = 'CM2'
const KEY_EQUIPMENT_TYPE = 'CM3'
# damage map keys
# average points of power across the stages of the combat style
const KEY_BASE_POWER = 'dm' 
# (damage types) Array of dicts (dmg_type -> relative power distribution) or single entries of possible damage types
# Ex: [Combat.PHYSICAL_DAMAGE, {Combat.PHYSICAL_DAMAGE:0.9, Combat.PHYSICAL_DEFEND:0.1}]]
# means half of the stances will consist only of physical damage, half will be physical damage + defend combined, and the combo 
# skills will tend to skew toward a 90%/10% distribution. A random number from 0 to 1.0 is added to each
# entry in a ratio dict to provide variance. If the end product of the variance should be low, use a larger number for the ratios.
# ex: 0.1/0.9 will give values between 0.1-1.1 vs 1.0-1.9, meaning the 0.1 value might take a bit more than 50% of the power allocation
# if it gets a 1.1 result and the 0.9 value gets a 1.0 result. 
# Meanwhile, a 1/9 value will give values between 1.0-2.0 vs 9.0-10.0, so the lower ratio value will be at most 2/9ths of the total power
# allocation
const KEY_DAMAGE_TYPES = 'dt'
# (variance) for each stance, a number from 0.0 to 1.0 is generated; if variance is 0, this number is directly used
#	If variance is nonzero, the variance is added to the generated number
#	After variance, all numbers are scaled so their sum is (1.0 * number of stages), then multiplied by the damage/defend value
#   Increasing variance value will actually decrease the total variance
const KEY_STANCE_VARIANCE  = 'v'
# (scaling attributes) array of possible scaling attributes; a random entry is taken for each stance within the style,
# and this attribute is used to determine damage/defense multipliers.
# Ex: [Stats.STRENGTH, Stats.STRENGTH, Stats.AGILITY] means that each stance has a 2/3 chance of being scaled by strength
const KEY_SCALING_STATS = 's' 
const KEY_STAT_MIN = 'sn'
const KEY_SCALING_MULTIPLIER = 'sm'

var equipment_type = Combat.EQUIP_HAND_TO_HAND
var stance_count:int = 4 # number of stances in styles created by this manual, plus or minus stance_count_variance
var stance_count_variance:int = 1 
var base_power:float = 5
var power_variance:float = 0
var damage_type_options:Array = [Combat.PHYSICAL_ATTACK]
var scaling_stat_options:Array = [Stats.STRENGTH]
var stat_min:float = 100.0
var scale_multiplier:float = 0.1

var study_owner_id # ID of the PC studying this manual; if it changes then we reset any progress they've made and set this to null
var previous_studiers = {} # ID -> number of times they've created a combat style with this book

func get_work_task_options(requestor:GameItem) -> Dictionary:
	var result = {}
	var student_id = requestor.get_id()
	var build_task_id = "%s%s" % [TASK_PREFIX_BUILD_STYLE, student_id]
	var build_task = WorkTaskOption.build(build_task_id, "Study combat", get_id(), "Study this manual and piece together a unique fighting style based on the philosophy it describes.", WorkTask.LOCATION_HELD | WorkTask.LOCATION_SHARED_ROOM)
	result[build_task_id] = build_task
	return self.work_task_list.filter_task_options(result, requestor)

func build_work_task(next_task:WorkTaskOption, contributor:GameItem) -> WorkTask:
	var task_id:String = next_task.get_id()
	if task_id.begins_with(TASK_PREFIX_BUILD_STYLE):
		return build_new_style_task(next_task, contributor)
	return null

func build_new_style_task(next_task:WorkTaskOption, contributor:GameItem):
	var task = WorkTask.new()
	task.auto_resolve = true
	var student_id = contributor.get_id()
	task.set_work_needed({WorkTypes.CONCENTRATION: 10 * (5 * previous_studiers.get(student_id, 0) + 1)})
	var pre_desc = "Blood, sweat, and intense concentration go into the genesis of a new fighting style.\nLuck and experience play a large role in the quality of the outcome."
	var work_result = WorkResult.new()
	task.set_description(pre_desc, null)
	task.set_work_result(work_result)
	return task

func pre_work_task_complete(task:WorkTask):
	var style = build_combat_style(task.get_contributors()[0])
	task.post_desc = "A new style is born: "+style.get_label()

# Called when creating object from WorkResult
func finish_resolve_item_result(args:Dictionary):
	stance_count = args.get(KEY_STANCE_COUNT)
	stance_count_variance = args.get(KEY_STANCE_COUNT_VARIANCE)
	base_power = args.get(KEY_BASE_POWER, 5.0)
	power_variance = args.get(KEY_STANCE_VARIANCE, 0.0)
	damage_type_options = args.get(KEY_DAMAGE_TYPES, [Combat.PHYSICAL_ATTACK, Combat.PHYSICAL_DEFEND])
	scaling_stat_options = args.get(KEY_SCALING_STATS, [Stats.STRENGTH])
	stat_min = args.get(KEY_STAT_MIN, 100)
	scale_multiplier = args.get(KEY_SCALING_MULTIPLIER, 0.1)
	equipment_type = args.get(KEY_EQUIPMENT_TYPE, Combat.EQUIP_HAND_TO_HAND)

func build_combat_style(student:PcItem):
	var stances = []
	var stance_power = []
	var stance_power_total = 0
	var style_power_adjustment = 1 * base_power * stance_count # base_power is average damage per stance
	var cur_stance_count = int(round(stance_count + randf()*stance_count_variance - randf()*stance_count_variance))
	for i in range(stance_count):
		stance_power.append(randf() + power_variance)
		stance_power_total += stance_power[i]
	for i in range(stance_count):
		stances.append(generate_stance(damage_type_options, (stance_power[i]/stance_power_total) * style_power_adjustment, scaling_stat_options, stat_min, scale_multiplier, 'Stance #'+str(i+1)))
	var result = CombatStyle.build(stances, equipment_type)
	var holder = get_closest_nonfolder_parent()
	result.__combatant = student
	study_owner_id = student.get_id() # just in case...
	result.allowed_owner_lock_id = study_owner_id
	previous_studiers[study_owner_id] = previous_studiers.get(study_owner_id, 0) + 1
	Events.add_game_item.emit(result, student, true)
	return result

func generate_stance(damage_type_options, base_power, scaling_stat_options, stat_min, scaling_multiplier, stance_name)->CombatStance:
	var damage_type_ratio_dict = damage_type_options[randi() % damage_type_options.size()]
	if !(damage_type_ratio_dict is Dictionary):
		damage_type_ratio_dict = {damage_type_ratio_dict:1.0}
	var damage_types = damage_type_ratio_dict.keys()
	var damage_division = []
	var total_damage_division = 0
	for k in damage_types:
		damage_division.append(randf() + damage_type_ratio_dict[k])
		total_damage_division += damage_division[-1]
	var final_damage = {}
	for i in range(damage_types.size()):
		final_damage[damage_types[i]] = (damage_division[i]/total_damage_division) * base_power
	var scaling_stat
	if !(scaling_stat_options is Array):
		scaling_stat = scaling_stat_options
	else:
		scaling_stat = scaling_stat_options[randi() % scaling_stat_options.size()]
	return CombatStance.build(damage_types, final_damage, scaling_stat, stat_min, scaling_multiplier, stance_name)

func get_action_panel_scene_path()->String:
	return "res://items/FlexibleItemActions.tscn"

func get_action_sections()->Array:
	return ['Description', 
		#['FlexibleButton', {
		#'button':'Create Combat Style', 
		#'click':'start_create_combat_style', 
		#'visible':'create_combat_style_visible'}],
		#'WorkNeeded'
	]

const SELF_TAGS3 = {Tags.TAG_EQUIPMENT:true, Tags.TAG_COMBAT_MANUAL:true}
const ALLOWED_TAGS3 = {}
func get_tags()->Dictionary:
	return SELF_TAGS3

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS3
	
func get_description():
	return "A collection of notes on various %s combat techniques. A dedicated student could develop one or more fighting styles from this." % [Combat.get_equipment_description(equipment_type)]

# takes an array of POSITIVE numbers (negatives will cause weird stuff)
# adds variance to each - 0 means that given [0, 1] we'll end up with [0, 1] as output; variance=1 means it becomes [0+1, 1+1] => [1, 2] => [0.333, 0.667]
# scales them so that their sum equals 1.0, while staying proportionally the same size
# multiplies them by scale_to so that the average per entry is scale_to
static func normalize_array(arr:Array, scale_to:float=1.0, variance:float=0.0)->PackedFloat32Array:
	var lowest = 9999999
	var size := arr.size()
	var result := PackedFloat32Array(arr)
	var total:float = 0
	for i in result:
		total += i + variance
	total /= scale_to
	for i in range(size):
		result[i] = (result[i]+variance)/total
	return result
