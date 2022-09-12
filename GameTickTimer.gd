extends Timer


# Called when the node enters the scene tree for the first time.
func _ready():
	connect('timeout', emit_tick)
	Events.connect('pre_load_game', pre_load_game)
	Events.connect('finalize_load_game', finalize_load_game)

func pre_load_game():
	disconnect('timeout', emit_tick)

func finalize_load_game():
	connect('timeout', emit_tick)

func emit_tick():
	Events.emit_signal('game_tick')


func _on_pause_button_pressed():
	self.paused = true

func _on_normal_speed_button_pressed():
	self.paused = false
	self.start(1)

func _on_2x_speed_button_2_pressed():
	self.paused = false
	self.start(1.0/2)


func _on_10x_speed_button_3_pressed():
	self.paused = false
	self.start(1.0/10)


func _on_30x_speed_button_4_pressed():
	self.paused = false
	self.start(1.0/30)
