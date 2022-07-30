extends WorkAwareItem
class_name EquipmentItem

# Set inherent_work_amounts to the base amount of the equipment
# Override the *_attunement_* functions as needed, or leave them alone for default attunement settings
# Each time attunement level changes, the work_amounts will be updated with a percentage of the inherent_work_amounts,
# giving a growing overall bonus 

const LOG_2 = log(2)

var attunement_progress:float = 0
var next_attunement_progress:float = 0
var attunement_owner = null

func _ready():
	connect('parent_updated', check_attunement_reset)

# finish_resolve_item_result args:
#   work_amounts: dictionary of WorkTypes -> float that's used for inherent_work_amounts
func finish_resolve_item_result(args):
	super.finish_resolve_item_result(args)

func get_action_panel_scene_path()->String:
	return "res://items/EquipmentItemActions.tscn"
	
func update_work_amounts():
	next_attunement_progress = get_attunement_progress_needed()
	var attunement = get_attunement_multiplier()
	work_amounts = {}
	for k in inherent_work_amounts:
		var inherent = inherent_work_amounts[k]
		work_amounts[k] = WorkAmount.new(inherent.work_type, inherent.effort, inherent.bonus, [])
		work_amounts[k].bonus = attunement

func reset_attunement():
	attunement_progress = 0
	update_work_amounts()

func add_attunement_progress(amt=0.5):
	if next_attunement_progress == 0:
		next_attunement_progress = get_attunement_progress_needed()
	attunement_progress += amt
	if attunement_progress >= next_attunement_progress:
		update_work_amounts()

func get_attunement_adjustment()->float:
	return LOG_2

func get_attunement_multiplier_per_level()->float:
	return 0.01

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
	return int(log(attunement_progress) / get_attunement_adjustment())

func get_attunement_progress()->float:
	return attunement_progress

func get_attunement_progress_needed()->float:
	return pow(get_attunement_level() + 1, get_attunement_adjustment())

func get_attunement_multiplier()->float:
	var val =  (get_attunement_level() * get_attunement_multiplier_per_level())
	return val if val > 0 else 0

const SELF_TAGS = {Tags.TAG_EQUIPMENT:true}
const ALLOWED_TAGS = {}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS
