extends RefCounted
class_name WorkTaskOption

var task_id
var task_name
var task_description
var task_source_id
var location_filter = WorkTask.DEFAULT_LOCATION_FILTER

static func build(task_id, task_name, task_source_id, task_description, location_filter=WorkTask.DEFAULT_LOCATION_FILTER):
	var result = WorkTaskOption.new()
	result.task_id = task_id
	result.task_name = task_name
	result.task_source_id = task_source_id
	result.task_description = task_description
	result.location_filter = location_filter
	return result

func get_id():
	return task_id

func get_source_id():
	return task_source_id

func get_label():
	return task_name

func get_description():
	return task_description

func get_task_name():
	return task_name
