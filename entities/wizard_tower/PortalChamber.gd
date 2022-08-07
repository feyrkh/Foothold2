extends LocationItem
class_name PortalChamber

var tutorial_goal_state

func get_description()->String:
	match tutorial_goal_state:
		PortalTutorialGoal.GOAL_CHAMBER_EXPLORED: return "A nondescript stone chamber. The room is choked with debris, making it difficult to move around. An arch is carved into one wall, but it leads nowhere - seamless stone fills it."
		PortalTutorialGoal.GOAL_DEBRIS_CLEARED, PortalTutorialGoal.GOAL_PORTAL_FOUND: return "With the debris piled neatly in one corner, nearly to the ceiling, it's now possible to reach the stone arch carved into the wall."
		PortalTutorialGoal.GOAL_PORTAL_ACTIVATED: return "The portal glows with a gentle, rippling light. While the portal itself is soothing to look upon, even hypnotic, its effect on the stone walls is rather unsettling. Somehow, everything the portal's light touches seems to waver like the surface of a lake lightly touched by the wind. It's a most unsettling motion to see in solid stone, let alone human flesh."
		_: return "(unexpected tutorial state: %s)" % [tutorial_goal_state]
