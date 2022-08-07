extends Section

# Called when the node enters the scene tree for the first time.
func _ready():
	get_game_item().stability_updated.connect(stability_updated)
	refresh()

func stability_updated(game_item):
	self.text = "Stability: %.1f" % [game_item.get_stability()]

func refresh():
	stability_updated(get_game_item())
