extends Section

func refresh():
	var item = get_game_item()
	self.text = "Attunement level: %d (%d/%d to next)\nAttunement bonus: +%.2f%%" % [item.get_attunement_level(), item.get_attunement_progress(), item.get_attunement_progress_needed(), 100*item.get_attunement_multiplier()]
