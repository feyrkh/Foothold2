extends MarginContainer

func set_text(msg):
	#print('writing message to ', self)
	if msg == null: 
		visible = false
	else: 
		visible = true
		$Label.text = msg

func _ready():
	Events.drag_error_msg.connect(set_text)
