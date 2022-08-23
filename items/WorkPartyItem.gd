extends GameItem
class_name WorkPartyItem

signal work_complete()

# Called when work is complete, but before the player clicks the 'complete' button (or before the task auto-resolves, if it does)
const WORK_COMPLETE_CALLBACK = 'wpWC'
# Called after the player clicks the 'complete' button (or after the task auto-resolves, if it does)
const RESOLVE_WORK_CALLBACK = 'wpRW'

const WORK_TARGET_ALL_SIMULTANEOUS = 1 << 0
const WORK_TARGET_ALL_SERIAL = 1 << 1
const WORK_TARGET_PARENT_ONLY = 1 << 2
const WORK_TARGET_SPECIFIC_ITEM = 1 << 3

var work_party_type:String = 'unknown'
var work_needed:Dictionary = {} # WorkTypes -> WorkAmount
var work_amounts:Dictionary = {} # WorkTypes -> WorkAmount
var max_workers:int = 1
var valid_work_target_types:int = WORK_TARGET_ALL_SERIAL | WORK_TARGET_ALL_SIMULTANEOUS | WORK_TARGET_PARENT_ONLY | WORK_TARGET_SPECIFIC_ITEM
var work_target_type:int = WORK_TARGET_ALL_SERIAL
var work_specific_target_id:int

var total_work_needed
var total_work_applied

var work_result:WorkResult
 
var auto_resolve = false # if true, the resolve_completion_effects call occurs automatically. Otherwise a button is added to the panel that must be clicked to resolve. 
var delete_on_resolve = true # if true, the resolve_completion_effects call will delete the work party item.

var work_paused:bool = false:
	get: return work_paused
	set(val):
		work_paused = val
		if !work_paused:
			Events.safe_connect('game_tick', game_tick)

func post_config(config:Dictionary):
	if work_needed != null:
		for k in work_needed:
			var entry_conf = work_needed[k]
			work_needed[k] = WorkAmount.build_from_config(entry_conf)
	if work_amounts != null:
		for k in work_amounts:
			var entry_conf = work_amounts[k]
			if entry_conf == null: continue
			work_amounts[k] = WorkAmount.build_from_config(entry_conf)
	work_result = WorkResult.build_from_config(config.get('work_result', null))

func init_work_party(label:String, work_party_type:String, work_needed:Dictionary):
	super.init(label)
	self.work_party_type = work_party_type
	self.work_needed = work_needed
	total_work_needed = 0
	total_work_applied = 0
	for work_type in work_needed.keys():
		var amt = work_needed[work_type]
		if !(amt is WorkAmount):
			amt = WorkAmount.new(work_type, amt, 0, {})
			work_needed[work_type] = amt
		total_work_needed += amt.get_total_effort()
	update_percentage_label()
	return self

func set_work_result(result:WorkResult):
	self.work_result = result

func is_work_complete()->bool:
	return work_needed == null || work_needed.is_empty()
	
func on_work_complete(work_party:WorkPartyItem):
	execute_callback(WORK_COMPLETE_CALLBACK)
	if auto_resolve:
		resolve_completion_effects()
	refresh_action_panel()

func resolve_completion_effects():
	if work_result:
		work_result.resolve_results()
	execute_callback(RESOLVE_WORK_CALLBACK)
	if delete_on_resolve:
		delete(true)

func update_percentage_label():
	if !tree_item or !is_instance_valid(tree_item):
		return
	if total_work_needed == 0:
		tree_item.set_text(0, label)
		return
	var pct = (total_work_applied/total_work_needed) * 100
	if pct == 0:
		tree_item.set_text(0, label)
	else:
		tree_item.set_text(0, label+' (%.0f%%)'%[pct])

func get_action_panel_scene_path()->String:
	return "res://items/WorkPartyItemActions.tscn"

func _ready():
	super._ready()
	Events.safe_connect('game_tick', game_tick)
	connect('contents_updated', update_work_amounts)
	connect('work_complete', on_work_complete)

func get_work_amounts():
	return work_amounts

func game_tick():
	var updated = false
	if work_paused:
		Events.disconnect('game_tick', game_tick)
		return
	if is_work_complete():
		Events.disconnect('game_tick', game_tick)
		return
	for work_type in work_amounts:
		var needed:WorkAmount = work_needed.get(work_type)
		var provided:WorkAmount = work_amounts.get(work_type)
		if !needed or !provided:
			continue
		var applied = min(needed.get_total_effort(), provided.get_total_effort())

		if applied >= 0:
			updated = true
			total_work_applied += applied
			refresh_action_panel()
			update_percentage_label()
			needed.apply_effort(applied)
			provided.on_effort_applied(work_type, applied)
			if needed.get_total_effort() < 0.000001:
				work_needed.erase(work_type)
				work_amounts.erase(work_type)
	if is_work_complete():
		emit_signal('work_complete', self)
		tree_item.set_icon(0, load("res://assets/icon/pin-1.png"))
		refresh_action_panel()
		return
	if updated:
		tree_item.set_icon(0, load("res://assets/icon/arrow-right.png"))
	else:
		Events.disconnect('game_tick', game_tick)
		tree_item.set_icon(0, null)
		
# Look for PCs 
func update_work_amounts():
	var workers:Array[GameItem] = super.find_child_items(_is_worker)
	update_work_amounts_from_worker_list(workers)

func update_work_amounts_from_worker_list(workers:Array[GameItem]):
	for work_type in work_needed:
		var amt:WorkAmount = null
		for worker in workers:
			var found_amt = worker.get_work_amount(work_type)
			if amt == null:
				amt = found_amt
			else:
				amt.add(found_amt)
		if amt != null:
			work_amounts[work_type] = amt
		else:
			work_amounts.erase(work_type)
	refresh_action_panel()
	Events.safe_connect('game_tick', game_tick)
	

func _is_worker(game_item:GameItem) -> bool:
	return game_item.has_method('get_work_amount')

const SELF_TAGS = {Tags.TAG_WORK:true}
const ALLOWED_TAGS = {Tags.TAG_PC:true}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS

func get_work_needed() -> Dictionary:
	return work_needed

func get_work_party_type() -> String:
	return work_party_type

func get_description():
	if !work_result:
		return null
	return work_result.post_complete_desc if is_work_complete() else work_result.pre_complete_desc 
