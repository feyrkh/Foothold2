extends Object
class_name SaveLoad

const SAVE_DIR := 'user://save_data/'
const SAVE_GAME_MAJOR_VERSION = 1
const SAVE_GAME_MINOR_VERSION = 1

const KEY_FILE = 'f'
const KEY_FILE_NAME = 'fname'
const KEY_SAVE_LABEL = 'label'
const KEY_MAJOR_VERSION = 'majver'
const KEY_MINOR_VERSION = 'minver'
const KEY_SAVE_TIME = 'save'

static func start_save_file(save_label:String, save_file_path:String) -> File:
	var f = File.new()
	var err = f.open(save_file_path, File.WRITE)
	if err != 0:
		printerr(save_file_path, " : Failed to open save file while saving, got error: ", err)
		return null
	f.store_var(SAVE_GAME_MAJOR_VERSION)
	f.store_var(SAVE_GAME_MINOR_VERSION)
	f.store_var(save_label)
	f.store_var(Time.get_datetime_string_from_system())
	return f

# Return val keys:
# file: open file handle, the header will already be read and calling code just needs to read in the right format and close the file when done
# KEY_MAJOR_VERSION: to compare against SAVE_GAME_MAJOR_VERSION
# KEY_MINOR_VERSION: to compare against SAVE_GAME_MINOR_VERSION
# KEY_SAVE_LABEL: user-provided name of the save file, for rendering in save game list
# save_time: timestamp string of when the file was saved, for sorting
static func open_load_file(save_file_path) -> Dictionary:
	var f = File.new()
	var err = f.open(save_file_path, File.READ)
	if err != 0:
		printerr(save_file_path, " : Failed to open save file while loading, got error: ", err)
		return {}
	var result = {}
	result[KEY_FILE] = f
	result[KEY_FILE_NAME] = save_file_path
	result[KEY_MAJOR_VERSION] = f.get_var()
	result[KEY_MINOR_VERSION] = f.get_var()
	result[KEY_SAVE_LABEL] = f.get_var()
	result[KEY_SAVE_TIME] = f.get_var()
	if result[KEY_MAJOR_VERSION] == null:
		result[KEY_MAJOR_VERSION] = 0
	if result[KEY_MINOR_VERSION] == null:
		result[KEY_MINOR_VERSION] = 0
	if result[KEY_SAVE_LABEL] == null:
		result[KEY_SAVE_LABEL] = '<corrupted: '+save_file_path.trim_prefix('user://')+'>'
	if result[KEY_SAVE_TIME] == null:
		result[KEY_SAVE_TIME] = '<corrupted save file>'
	return result

static func find_next_save_slot() -> String:
	var save_dir = Directory.new()
	if !save_dir.dir_exists(SAVE_DIR):
		save_dir.make_dir(SAVE_DIR)
	var err = save_dir.open(SAVE_DIR)
	if err:
		push_error("Couldn't open savegame directory: ", err)
		return '0.sav'
	var save_slot = 1
	while save_dir.file_exists(str(save_slot)+'.sav'):
		save_slot += 1
	return str(save_slot)+'.sav'

static func get_save_dir() -> Directory:
	var save_dir := Directory.new()
	if !save_dir.dir_exists(SaveLoad.SAVE_DIR):
		save_dir.make_dir(SaveLoad.SAVE_DIR)
	save_dir.open(SAVE_DIR)
	return save_dir
