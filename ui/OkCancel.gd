extends HBoxContainer

signal ok_button_pressed()
signal cancel_button_pressed()

@onready var OkButton:Button = find_child('OkButton')
@onready var CancelButton:Button = find_child('CancelButton')

func set_ok_enabled(val):
	OkButton.disabled = !val

func get_ok_disabled():
	return OkButton.disabled

func _on_cancel_button_pressed():
	emit_signal("cancel_button_pressed")

func _on_ok_button_pressed():
	emit_signal("ok_button_pressed")
