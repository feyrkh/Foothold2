extends AreaItem

var explore_rooms_found = 0

func has_more_explore_locations():
	return true

func get_next_explore_location():
	var room = load("res://entities/wizard_tower/SmallChamber.gd").new("Small Chamber")
	return room

func get_explore_effort_needed():
	return 30 * (2 ** explore_rooms_found)
	
func get_description():
	return """
	This ancient tower is falling apart. Debris litters its corridors, the steps of the staircase
	that winds around the outside edge are wobbly, broken, or entirely missing, and doors are 
	locked or blocked from the inside by falling masonry. Just exploring the interior will take
	time, to say nothing of the effort that any repairs will require.
	"""

func get_explore_description():
	match explore_rooms_found:
		0: return "Step into the forbidding edifice, and begin to clear it."
		1: return "Batter down a locked door and reveal a new room."
		2: return "Clear fallen masonry which blocks a large storerooom."
		_: return "The remaining rooms are choked with debris and require extensive repairs."
