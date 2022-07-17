extends AreaItem

func has_more_explore_locations():
	return true

func get_next_explore_location():
	var room = load("res://entities/wizard_tower/SmallChamber.gd").new("Small Chamber")
	return room
	
func get_description():
	return """
	This ancient tower is falling apart. Debris litters its corridors, the steps of the staircase
	that winds around the outside edge are wobbly, broken, or entirely missing, and doors are 
	locked or blocked from the inside by falling masonry. Just exploring the interior will take
	time, to say nothing of the effort that any repairs will require.
	"""
