extends Object
class_name Combat

const PHYSICAL_ATTACK = 0
const PHYSICAL_DEFEND = 1
const IMPURE_VIS_ATTACK = 2
const IMPURE_VIS_DEFEND = 3 

static func get_damage_short_element(damage_type:int):
	match damage_type:
		PHYSICAL_ATTACK, PHYSICAL_DEFEND: return 'phys'
		IMPURE_VIS_ATTACK, IMPURE_VIS_DEFEND: return 'vis'
		_: return 'unknown'

static func is_attack(damage_type:int)->bool:
	return posmod(damage_type, 2) == 0

static func is_defend(damage_type:int) -> bool:
	return posmod(damage_type, 2) == 1

const EQUIP_HAND_TO_HAND = 0

static func balanced_options(balance, attack_opts, defend_opts, balance_opts=null):
	match balance:
		'attack': return attack_opts
		'defend': return defend_opts
		_: 
			if balance_opts == null:
				var result = []
				result = result.append_array(attack_opts)
				result = result.append_array(defend_opts)
				return result
			

static func get_equipment_description(equip_type:int)->String:
	match equip_type:
		EQUIP_HAND_TO_HAND: return "hand-to-hand"
		_: return "unknown"

static func get_damage_type_attack_names(damage_type) -> Array:
	var opts = []
	match damage_type:
		Combat.PHYSICAL_ATTACK: 
			opts.append_array(['Slam', 'Drop', 'Attack', 'Strike', 'Punch', 'Chop'])
		Combat.PHYSICAL_DEFEND: 
			opts.append_array(['Block', 'Guard', 'Defense', 'Parry', 'Deflect'])
		Combat.IMPURE_VIS_ATTACK: 
			opts.append_array(['Bolt', 'Wave', 'Fan'])
		Combat.IMPURE_VIS_DEFEND:
			opts.append_array(['Cloak', 'Aura', 'Shell'])
	return opts

static func get_damage_type_nouns(power_type) -> Array:
	var opts = []
	match power_type:
		Combat.PHYSICAL_ATTACK: 
			opts.append_array(['Hammer', 'Twist'])
		Combat.PHYSICAL_DEFEND: 
			opts.append_array(['Wall'])
		Combat.IMPURE_VIS_ATTACK: 
			opts.append_array(['Spirit'])
		Combat.IMPURE_VIS_DEFEND:
			opts.append_array(['Spirit'])
	return opts

static func get_equipment_type_attack_names(equipment_type, balance) -> Array:
	var opts = []
	match equipment_type:
		Combat.EQUIP_HAND_TO_HAND: 
			opts.append_array(balanced_options(balance, 
				['Choke', 'Fist', 'Foot', 'Kick', 'Leg', 'Hand', 'Knee', 'Elbow', 'Sole'], 
				['Grip', 'Block', 'Dodge', 'Diversion'], 
				['Brawl', 'Grapple', 'Claw'] 
			))
	return opts
	
static func get_equipment_type_nouns(equipment_type, balance) -> Array:
	var opts = []
	match equipment_type:
		Combat.EQUIP_HAND_TO_HAND: opts.append_array([])
	opts.append(['Ghost', 'Spirit', 'Heaven', 'Mouse', 'Monkey', 'Dragon', 'Phoenix', 'Demon', 'Angel', 'Shaman'])
	return opts

static func get_scaling_stat_attack_names(scaling_stat:int, balance) -> Array:
	var opts = []
	match scaling_stat:
		Stats.STRENGTH:
			opts.append_array(['Bite', 'Fist', 'Pummel', 'Toss', 'Attack', 'Strike', 'Elbow'])
		Stats.AGILITY:
			opts.append_array(['Grab', 'Dart', 'Leap', 'Trip', 'Drop', 'Pose', 'Stance'])
		Stats.INTELLIGENCE:
			opts.append_array(['Meditation', 'Insight'])
		Stats.WILLPOWER:
			opts.append_array(['Palm', 'Will'])
		Stats.CONSTITUTION:
			opts.append_array(['Choke','Grapple', 'Clutch', 'Clinch', 'Tackle'])
		Stats.PERCEPTION:
			opts.append_array([])
	return opts

static func get_scaling_stat_nouns(scaling_stat:int, balance) -> Array:
	var opts = []
	match scaling_stat:
		Stats.STRENGTH:
			opts.append_array(['Avalanche', 'Bull', 'Bear', 'Muscle', 'Barbarian', 'Hammer',])
		Stats.AGILITY:
			opts.append_array(['Shadow', 'Cat', 'Weasel', 'Thief'])
		Stats.INTELLIGENCE:
			opts.append_array(['Owl', 'Serpent', 'Dragon', 'Mind', 'Crystal'])
		Stats.WILLPOWER:
			opts.append_array(['Cloud', 'Wisdom', 'Palm', 'Panic', 'Ghost', 'Storm', 'Agony'])
		Stats.CONSTITUTION:
			opts.append_array(['Ox', 'Boar', 'Madman'])
		Stats.PERCEPTION:
			opts.append_array(['Eye', 'Ear', 'Vision', 'Touch', 'Eagle', 'Phantom'])
	return opts

static func get_scaling_stat_adjectives(scaling_stat:int, balance) -> Array:
	var opts = []
	match scaling_stat:
		Stats.STRENGTH:
			opts.append_array(['Fatal', 'Terrible', 'Beastly'])
		Stats.AGILITY:
			opts.append_array(['Quick', 'Maneuvering', 'Twisted', 'Agile', 'Airborne', 'Assassin'])
		Stats.INTELLIGENCE:
			opts.append_array(['Sharp', 'Brilliant', 'Tricky', 'Uncounted', 'Premeditated', 'Thoughtful'])
		Stats.WILLPOWER:
			opts.append_array(['Drunken', 'Persistent', 'Adamant', 'Blessed', 'Dreaded'])
		Stats.CONSTITUTION:
			opts.append_array(['Terrible', 'Guardian'])
		Stats.PERCEPTION:
			opts.append_array(['Invisible', 'Unseen', 'Inescapable'])
	return opts

static func get_scaling_stat_verbs(scaling_stat:int, balance) -> Array:
	var opts = []
	match scaling_stat:
		Stats.STRENGTH:
			opts.append_array(['Crushing', 'Smashing'])
		Stats.AGILITY:
			opts.append_array(['Floating','Leaping'])
		Stats.INTELLIGENCE:
			opts.append_array(['Unveiling', 'Maneuvering', 'Tricking'])
		Stats.WILLPOWER:
			opts.append_array(['Submitting', 'Resisting', 'Transforming'])
		Stats.CONSTITUTION:
			opts.append_array(['Enduring', 'Fatiguing', ''])
		Stats.PERCEPTION:
			opts.append_array(['Revealing', 'Concealing', 'Searching', ])
	return opts

static func get_damage_type_adjectives(power_type) -> Array:
	var opts = []
	match power_type:
		Combat.PHYSICAL_ATTACK: 
			opts.append_array([])
		Combat.PHYSICAL_DEFEND: 
			opts.append_array(['Guardian'])
		Combat.IMPURE_VIS_ATTACK: 
			opts.append_array([])
		Combat.IMPURE_VIS_DEFEND:
			opts.append_array([])
	return opts
	
static func get_equipment_type_adjectives(equipment_type, balance) -> Array:
	var opts = []
	match equipment_type:
		Combat.EQUIP_HAND_TO_HAND: opts.append_array(['Unarmed', 'Empty-handed', 'Open', 'Closed'])
	opts.append_array(balanced_options(balance, ['Mighty'], ['Cowardly'], []))
	opts.append(['Wicked', 'Righteous', 'Blessed', 'Cursed'])
	return opts
	
static func get_damage_type_verbs(power_type) -> Array:
	var opts = []
	match power_type:
		Combat.PHYSICAL_ATTACK: 
			opts.append_array(['Striking', 'Smashing', 'Impacting'])
		Combat.PHYSICAL_DEFEND: 
			opts.append_array(['Blocking', 'Deflecting'])
		Combat.IMPURE_VIS_ATTACK: 
			opts.append_array(['Shoving'])
		Combat.IMPURE_VIS_DEFEND:
			opts.append_array(['Veiling'])
	return opts
	
static func get_equipment_type_verbs(equipment_type, balance) -> Array:
	var opts = []
	match equipment_type:
		Combat.EQUIP_HAND_TO_HAND: opts.append_array([])
	return opts
	
static func get_attack_type_name_opts(power_type, equipment_type, attack_power) -> Array:
	var attack_type_opts = [] # verbs or '<noun> of'
	match power_type:
		Combat.PHYSICAL_ATTACK: 
			attack_type_opts.append_array(['Striking', '', 'Smashing', 'Hammer', 'Impacting'])
		Combat.PHYSICAL_DEFEND: 
			attack_type_opts.append_array(['Wall of', '', 'Guardian', 'Blocking', 'Deflecting'])
		Combat.IMPURE_VIS_ATTACK: 
			attack_type_opts.append_array(['Force', 'Vis', 'Shoving'])
		Combat.IMPURE_VIS_DEFEND:
			attack_type_opts.append_array(['Shell', 'Imbued'])
		_:
			push_error('Unexpected power_type when generating attack_type_name in a new style: ', power_type)
			attack_type_opts.append(null)
	return attack_type_opts

static func get_equipment_name_opts(power_type, equipment_type, attack_power) -> Array:
	var equipment_opts = [] # nouns
	match power_type:
		Combat.PHYSICAL_ATTACK: pass
		Combat.PHYSICAL_DEFEND: pass
		Combat.IMPURE_VIS_ATTACK: 
			equipment_opts.append_array(['Bolt', 'Wave', 'Fan', 'Will'])
		Combat.IMPURE_VIS_DEFEND:
			equipment_opts.append_array(['Cloak', 'Domain', 'Shell'])
		_:
			push_error('Unexpected power_type when generating equipment_name in a new style: ', power_type)
	match equipment_type:
		Combat.EQUIP_HAND_TO_HAND: equipment_opts.append_array(['Fist', 'Foot', 'Kick', 'Leg', 'Hand', 'Grapple', 'Brawl', 'Grip', 'Knee', 'Elbow', 'Sole'])
		_: 
			push_error('Unexpected equipment_type when generating equipment_name in a new style: ', equipment_type)
			equipment_opts.append_array(['Style'])
	return equipment_opts

static func get_power_distribution_name_opts(total_attack_power, total_defend_power):
	var adjective_opts = [] # adjectives, duh
	total_attack_power = total_attack_power / (total_attack_power + total_defend_power)
	total_defend_power = total_defend_power / (total_attack_power + total_defend_power)
	if total_attack_power == 0:
		adjective_opts.append_array(['Pure Defense', 'Impenetrable', 'Cowardly'])
	elif total_attack_power < 0.25:
		adjective_opts.append_array(['Defensive', 'Guarded', 'Slippery'])
	elif total_attack_power < 0.5:
		adjective_opts.append_array(['Drunken', 'Cautious', 'Reserved'])
	elif total_attack_power < 0.75:
		adjective_opts.append_array(['Balanced', 'Opposed'])
	elif total_attack_power < 1.0:
		adjective_opts.append_array(['Offensive', 'Aggressive', 'Rush', 'Potent'])
	else:
		adjective_opts.append_array(['Brutal', 'Bestial', 'Demonic', 'indomitable'])
	return adjective_opts
