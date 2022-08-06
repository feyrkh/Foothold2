extends WorkAwareItem
class_name EquipmentItem

# Set inherent_work_amounts to the base amount of the equipment
# Override the *_attunement_* functions as needed, or leave them alone for default attunement settings
# Each time attunement level changes, the work_amounts will be updated with a percentage of the inherent_work_amounts,
# giving a growing overall bonus 

const KEY_ATTUNE_MULTIPLIER = 'ei_att_mul' # finish_resolve_item_result key: multiply attunement level by this to get effort modifier
const KEY_ATTUNE_PROGRESS_MULTIPLIER = 'ei_pro_mul' # finish_resolve_item_result key: multiply progress needed by this; ex: 1.0 means every level costs 2x the previous (1, 2, 4, ...) 10.0 means we multiply the default value by 10 (10, 20, 40)

var attunement_progress:float = 0
var attunement_multiplier:float = 0.1
var next_attunement_progress:float = 0
var next_attunement_progress_multiplier:float = 1.0

var attunement_owner = null

func _ready():
	connect('parent_updated', check_attunement_reset)

# finish_resolve_item_result args:
#   work_amounts: dictionary of WorkTypes -> float that's used for inherent_work_amounts
#   KEY_ATTUNE_MULTIPLIER: 
func finish_resolve_item_result(args):
	super.finish_resolve_item_result(args)
	attunement_multiplier = args.get(KEY_ATTUNE_MULTIPLIER, 0.1)
	next_attunement_progress_multiplier = args.get(KEY_ATTUNE_PROGRESS_MULTIPLIER, 1.0)

func on_effort_applied():
	add_attunement_progress(1)

func update_work_amounts():
	next_attunement_progress = get_attunement_progress_needed()
	var attunement = get_attunement_multiplier()
	work_amounts = {}
	for k in inherent_work_amounts:
		var inherent = inherent_work_amounts[k]
		work_amounts[k] = WorkAmount.new(inherent.work_type, inherent.effort, inherent.bonus, {get_id():1})
		work_amounts[k].bonus = attunement
	update_parent_work_amounts()
	refresh_action_panel()
	

func reset_attunement():
	attunement_progress = 0
	update_work_amounts()

func add_attunement_progress(amt=0.5):
	if next_attunement_progress == 0:
		next_attunement_progress = get_attunement_progress_needed()
	attunement_progress += amt
	if attunement_progress >= next_attunement_progress:
		update_work_amounts()
	else:
		refresh_action_panel()

func get_attunement_adjustment()->float:
	return 2.0

func get_attunement_multiplier_per_level()->float:
	return attunement_multiplier

func check_attunement_reset(old_parent, new_parent):
	# Find the closest non-folder parents, if we're moving to/from a folder
	if old_parent != null and (old_parent is FolderItem):
		old_parent = old_parent.get_closest_nonfolder_parent()
	if new_parent != null and (new_parent is FolderItem):
		new_parent = new_parent.get_closest_nonfolder_parent()
	# reset attunment if we moved
	if new_parent == null:
		reset_attunement()
	elif attunement_owner != new_parent.get_id():
		reset_attunement()
		attunement_owner = new_parent.get_id()
	# force old and new parents to update their work types
	if old_parent and is_instance_valid(old_parent) and old_parent.has_method('update_work_types'):
		old_parent.update_work_types()
	if new_parent and new_parent.has_method('update_work_types'):
		new_parent.update_work_types()

func get_attunement_level()->int:
	if attunement_progress == 0:
		return 0
	var level = int(log(attunement_progress/next_attunement_progress_multiplier) / log(get_attunement_adjustment()))
	if level < 1:
		level = 0
	return level

func get_attunement_progress()->float:
	return attunement_progress

func get_attunement_progress_needed()->float:
	return next_attunement_progress_multiplier * pow(get_attunement_adjustment(), get_attunement_level() + 1)

func get_attunement_multiplier()->float:
	var val =  (get_attunement_level() * get_attunement_multiplier_per_level())
	return val if val > 0 else 0.0

func get_action_panel_scene_path()->String:
	return "res://items/FlexibleItemActions.tscn"

const ACTION_SECTIONS = ['Description', 'Attunement', 'WorkProvided']
func get_action_sections()->Array:
	return ACTION_SECTIONS

const SELF_TAGS = {Tags.TAG_EQUIPMENT:true}
const ALLOWED_TAGS = {}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS
