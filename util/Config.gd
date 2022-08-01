extends Object
class_name Config

const IGNORE_FIELD_NAMES = {
	"Reference":true, "script":true, "Script Variables":true, "owner":true, "Node":true, "_import_path":true, "name":true, "unique_name_in_owner":true,
	"scene_file_path":true, "multiplayer": true, "Process": true, "process_mode":true, "process_priority":true, "Editor Description":true, "editor_description":true,
}
var prop_cache = {}

static func config(obj, c):
	if c == null:
		return
	var props = obj.get_property_list()
	var propNames = {}
	var propTypes = {}
	# TODO: find a way to reduce the wasted cycles here
	for prop in props:
		propNames[prop.name] = true
		propTypes[prop.name] = prop.type
	for fieldName in c.keys():
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
		if IGNORE_FIELD_NAMES.has(prop.name):
			continue
		if object_ignore_field_names != null and object_ignore_field_names.has(prop.name):
			continue
		var config_value = to_config_field(obj, prop)
		if config_value != null:
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
		var arr = []
		for entry in obj.get(prop.name):
			if entry is Object:
				arr.append(to_config(entry))
			else:
				arr.append(entry)
		return arr
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
