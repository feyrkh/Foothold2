extends WorkHeldItem
class_name CombatManual

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

func _ready():
	super._ready()
	set_callback(self.WORK_COMPLETE_CALLBACK, self.get_id(), 'build_combat_style') # don't forget the callback must take 1 arg, the WorkParty object

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

func build_combat_style(work_party):
	var stances = []
	var stance_power = []
	var stance_power_total = 0
	var style_power_adjustment = 1 * base_power * stance_count # base_power is average damage per stance
	var cur_stance_count = int(round(stance_count + randf()*stance_count_variance - randf()*stance_count_variance))
	for i in range(stance_count):
		stance_power.append(randf() + power_variance)
		stance_power_total += stance_power[i]
	for i in range(stance_count):
		stances.append(generate_stance(damage_type_options, (stance_power[i]/stance_power_total) * style_power_adjustment, scaling_stat_options, stat_min, scale_multiplier))
	var result = CombatStyle.build(stances, equipment_type)
	var holder = get_closest_nonfolder_parent()
	study_owner_id = holder.get_id() # just in case...
	result.allowed_owner_lock_id = study_owner_id
	previous_studiers[study_owner_id] = previous_studiers.get(study_owner_id, 0) + 1
	Events.add_game_item.emit(result, holder, true)
	clear_work()
	refresh_action_panel()

func generate_stance(damage_type_options, base_power, scaling_stat_options, stat_min, scaling_multiplier)->CombatStance:
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
	return CombatStance.build(damage_types, final_damage, scaling_stat, stat_min, scaling_multiplier)

func get_action_panel_scene_path()->String:
	return "res://items/FlexibleItemActions.tscn"

func get_action_sections()->Array:
	return ['Description', ['FlexibleButton', {
		'button':'Create Combat Style', 
		'click':'start_create_combat_style', 
		'visible':'create_combat_style_visible'}],
		'WorkNeeded'
	]

const SELF_TAGS3 = {Tags.TAG_EQUIPMENT:true, Tags.TAG_COMBAT_MANUAL:true}
const ALLOWED_TAGS3 = {}
func get_tags()->Dictionary:
	return SELF_TAGS3

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS3
	
func get_description():
	return "A collection of notes on various %s combat techniques. A dedicated student could develop one or more fighting styles from this." % [Combat.get_equipment_description(equipment_type)]

func moved_parents(old_parent, new_parent):
	super(old_parent, new_parent)
	var holder = get_closest_nonfolder_parent()
	if holder.get_id() != study_owner_id:
		study_owner_id = null
		clear_work()

func clear_work():
	total_work_needed = 0
	total_work_applied = 0
	work_needed = {}
	work_amounts = {}
	update_percentage_label()
	tree_item.set_icon(0, null)
	work_paused = true

func create_combat_style_visible():
	return total_work_needed == 0 and get_closest_nonfolder_parent() is PcItem

func start_create_combat_style():
	var study_owner = get_closest_nonfolder_parent()
	if !study_owner is PcItem:
		refresh_action_panel()
		return
	study_owner_id = study_owner.get_id()
	var concentration_needed = pow(5, previous_studiers.get(study_owner_id, 0)) * 10
	init_work_party(get_label(), Tags.WORK_PARTY_DESIGN_COMBAT_STYLE, {WorkTypes.CONCENTRATION: concentration_needed})
	work_paused = true
	update_work_amounts()
	refresh_action_panel()

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
