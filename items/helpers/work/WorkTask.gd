# in-progress task, with specific amounts of work remaining and reward config
extends RefCounted
class_name WorkTask

const LOCATION_SELF = 1 # used to filter work tasks that can only be started by their source object, ex: meditation
const LOCATION_SHARED_ROOM = 2 # used to filter tasks that can only be started if the worker shares a room with the source object, ex: exercise with equipment
const LOCATION_INSIDE = 4 # used to filter tasks that can only be started if the worker is inside the source object, ex: explore an area
const LOCATION_HELD = 8 # used to filter tasks that can only be started if the worker is holding the source object, ex: consuming a single-use item?
const DEFAULT_LOCATION_FILTER = LOCATION_SELF | LOCATION_SHARED_ROOM | LOCATION_INSIDE | LOCATION_HELD

var task_source_id # ID of the GameItem that produces this task
var work_result:WorkResult
var work_needed:Dictionary = {} # WorkTypes -> WorkAmount
var task_name
var task_description
var location_filter = DEFAULT_LOCATION_FILTER

func check_allowed_worker(worker):
	if !allowed_position_relationship(IdManager.get_item_by_id(task_source_id), worker, location_filter):
		return false
	# TODO: worker is capable of the kind of work we need?
	return true

static func allowed_position_relationship(work_target:GameItem, requestor:GameItem, location_filter):
	if work_target == null or requestor == null:
		return false
	if location_filter & LOCATION_SELF:
		if work_target == requestor:
			return true
	if location_filter & LOCATION_SHARED_ROOM:
		if work_target.find_sibling_items(func(item): return item == requestor).size() > 0:
			return true
	if location_filter & LOCATION_INSIDE:
		if work_target.find_child_items(func(item): return item == requestor).size() > 0:
			return true
	if location_filter & LOCATION_HELD:
		if requestor.find_child_items(func(item): return item == requestor).size() > 0:
			return true
	return false

func get_label():
	return task_name

func get_description():
	return task_description
