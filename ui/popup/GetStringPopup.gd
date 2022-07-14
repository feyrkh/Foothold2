extends PopupPanel

signal ok_button_pressed(new_folder_name)

@onready var FolderName:LineEdit = find_child('Folder')
@onready var OkCancelButtons = find_child('OkCancel')

var is_path_string = false # if true, don't allow some special characters in the returned string
var allow_empty = false # if true, allow empty  strings

# Called when the node enters the scene tree for the first time.
func _ready():
	OkCancelButtons.set_ok_enabled(false)
	OkCancelButtons.connect('ok_button_pressed', ok)
	OkCancelButtons.connect('cancel_button_pressed', cancel)
	OkCancelButtons.connect('visibility_changed', focus_on_folder)
	if get_parent() == get_tree().root:
		popup()

func ok():
	emit_signal('ok_button_pressed', FolderName.get_text())
	queue_free()

func cancel():
	queue_free()

func _on_folder_text_changed(new_text):
	if is_path_string and new_text.find('/') >= 0:
		FolderName.text = FolderName.text.replace('/', '\\')
		FolderName.caret_position = FolderName.text.length()
	OkCancelButtons.set_ok_enabled(!FolderName.text.strip_edges().is_empty())


func _on_folder_text_submitted(new_text):
	if !OkCancelButtons.get_ok_disabled():
		ok()

func focus_on_folder():
	await get_tree().process_frame
	FolderName.grab_focus()
