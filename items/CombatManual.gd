extends GameItem
class_name CombatManual

# number of stances in the style
const KEY_STANCE_COUNT = 'CM1'

# damage map keys
# average points of power across the stages of the combat style
const KEY_BASE_POWER = 'dm' 
# (damage types) Array of arrays or single entries of possible damage types
# Ex: [Combat.PHYSICAL_DAMAGE, [Combat.PHYSICAL_DAMAGE, Combat.PHYSICAL_DEFEND]]
# means half of the stances will consist only of physical damage, half will be physical damage + defend combined
# Multiple damage types in a single stance will have the total damage divided randomly between them
const KEY_DAMAGE_TYPES = 'dt'
# (variance) for each stage, a number from 0.0 to 1.0 is generated; if variance is 0, this number is directly used
#	If variance is nonzero, the variance is added to the generated number
#	After variance, all numbers are scaled so their sum is (1.0 * number of stages), then multiplied by the damage/defend value
const KEY_VARIANCE = 'v'
# (scaling attributes) array of possible scaling attributes; a random entry is taken for each stance within the style,
# and this attribute is used to determine damage/defense multipliers.
# Ex: [Stats.STRENGTH, Stats.STRENGTH, Stats.AGILITY] means that each stance has a 2/3 chance of being scaled by strength
const KEY_SCALING_STATS = 's' 
const KEY_STAT_MIN = 'sn'
const KEY_SCALING_MULTIPLIER = 'sm'

var stances:Array

# Called when creating object from WorkResult
func finish_resolve_item_result(args:Dictionary):
	stances = []
	var stance_power = []
	var stance_count = args.get(KEY_STANCE_COUNT)
	var base_power = args.get(KEY_BASE_POWER, 5.0)
	var damage_type_options = args.get(KEY_DAMAGE_TYPES, [Combat.PHYSICAL_ATTACK, Combat.PHYSICAL_DEFEND])
	var scaling_stat_options = args.get(KEY_SCALING_STATS, [Stats.STRENGTH])
	var stat_min = args.get(KEY_STAT_MIN, 100)
	var scale_multiplier = args.get(KEY_SCALING_MULTIPLIER, 0.1)
	var stance_power_total = 0
	for i in range(stance_count):
		stance_power.append(randf() + args.get(KEY_VARIANCE, 0.0))
		stance_power_total += stance_power[i]
		
	for i in range(stance_count):
		stances.append(generate_stance(damage_type_options, (stance_power[i]/stance_power_total) * base_power, scaling_stat_options, stat_min, scale_multiplier))

func generate_stance(damage_type_options, base_power, scaling_stat_options, stat_min, scaling_multiplier)->CombatStance:
	var damage_types = damage_type_options[randi() % damage_type_options.size()]
	if !(damage_types is Dictionary):
		damage_types = [damage_types]
	var damage_division = []
	var total_damage_division = 0
	for i in range(damage_types.size()):
		damage_division.append(randf())
		total_damage_division = damage_division[i]
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

const ACTION_SECTIONS = ['Description']
func get_action_sections()->Array:
	return ACTION_SECTIONS

const SELF_TAGS = {Tags.TAG_EQUIPMENT:true, Tags.TAG_COMBAT_MANUAL:true}
const ALLOWED_TAGS = {}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS
	
func get_description():
	return "A cool guy."

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
