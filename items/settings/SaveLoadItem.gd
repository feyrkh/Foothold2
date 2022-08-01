extends GameItem


var save_files:Dictionary = {}

func skip_save() -> bool:
	return true

func _ready():
	super._ready()
	refresh_save_files()

func refresh_save_files():
	save_files = {}
	for save_file_name in get_save_files():
		var save_info:Dictionary = SaveLoad.open_load_file(SaveLoad.SAVE_DIR+save_file_name)
		if save_info[SaveLoad.KEY_FILE] and save_info[SaveLoad.KEY_FILE].is_open():
			save_info[SaveLoad.KEY_FILE].close()
			save_info.erase(SaveLoad.KEY_FILE)
			save_files[save_file_name] = save_info

func get_save_files() -> PackedStringArray:
	var save_dir = SaveLoad.get_save_dir()
	return save_dir.get_files()

const SELF_TAGS = {}
const ALLOWED_TAGS = {}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS

func get_action_panel_scene_path()->String:
	return "res://items/settings/SaveLoadItemActions.tscn"

func can_rename()->bool:
	return false
