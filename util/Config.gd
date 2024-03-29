extends Object
class_name Config

const IGNORE_FIELD_NAMES = {
	"Reference":true, "script":true, "Script Variables":true, "owner":true, "Node":true, "_import_path":true, "name":true, "unique_name_in_owner":true,
	"scene_file_path":true, "multiplayer": true, "Process": true, "process_mode":true, "process_priority":true, "Editor Description":true, "editor_description":true,
}
const IGNORE_CLASS_NAMES = {
	"TreeItem":true
}

var prop_cache = {}

static func config(obj, c):
	if c == null:
		return
	var props = obj.get_property_list()
	var propNames = {}
	var propTypes = {}
	# TODO: find a way to reduce the wasted cycles here
	var object_ignore_field_names:Dictionary
	if obj.has_method('get_ignore_field_names'):
		object_ignore_field_names = obj.get_ignore_field_names()
	for prop in props:
		propNames[prop.name] = true
		propTypes[prop.name] = prop.type
	for fieldName in c.keys():
		if object_ignore_field_names != null and object_ignore_field_names.has(fieldName):
			continue
		if propNames.has(fieldName):
			if propTypes[fieldName] == TYPE_OBJECT:
				var existing_obj = obj.get(fieldName)
				if existing_obj:
					if existing_obj.has_method("_from_config"):
						existing_obj._from_config(c[fieldName])
					else:
						config(existing_obj, c[fieldName])
			else:
				obj.set(fieldName, c[fieldName])
	if obj.has_method("post_config"):
		obj.post_config(c)
	return obj

static func to_config(obj):
	if !(obj is Object):
		return obj
	if obj.has_method('_to_config'):
		return obj._to_config()
	var props = obj.get_property_list()
	var result = {}
	var object_ignore_field_names:Dictionary
	if obj.has_method('get_ignore_field_names'):
		object_ignore_field_names = obj.get_ignore_field_names()
	for prop in props:
		if prop.name.begins_with('__'):
			continue
		if IGNORE_CLASS_NAMES.has(prop['class_name']):
			continue
		if IGNORE_FIELD_NAMES.has(prop.name):
			continue
		if object_ignore_field_names != null and object_ignore_field_names.has(prop.name):
			continue
		var config_value = to_config_field(obj, prop)
		if config_value != null and !(config_value is RefCounted) and !(config_value is Node):
			if config_value is Array:
				result[prop.name] = config_value.map(func(val): return to_config(val))
			elif config_value is Dictionary:
				var d = {}
				for k in config_value:
					d[k] = to_config(config_value[k])
				result[prop.name] = d
			else:
				result[prop.name] = config_value
			
	return result

static func to_config_field(obj, prop):
	if prop["type"] == TYPE_OBJECT:
		var fieldVal = obj.get(prop.name)
		if !fieldVal:
			return null
		if fieldVal.has_method("_to_config"):
			return fieldVal._to_config()
		else:
			return to_config(fieldVal)
	if prop["type"] == TYPE_ARRAY:
		var arr = obj.get(prop.name)
		return arr.map(func(entry):
			if entry is Object: return to_config(entry)
			else: return entry)
	if prop["type"] == TYPE_DICTIONARY:
		var orig = obj.get(prop.name)
		if orig == null:
			return null
		var new_dict = {}
		for k in orig:
			new_dict[k] = to_config(orig[k])
		return new_dict
	else:
		return obj.get(prop.name)
