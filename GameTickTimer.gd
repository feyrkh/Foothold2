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
