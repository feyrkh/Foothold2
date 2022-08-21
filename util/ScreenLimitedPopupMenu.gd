extends PopupMenu
class_name ScreenLimitedPopupMenu

func popup_on_screen(pos:Vector2):
	super.popup()
	var viewport_size = get_parent().get_viewport().get_visible_rect().size
	position = pos
	var right_side = position.x + size.x
	var bottom_side = position.y + size.y
	var right_overhang = max(0, right_side - viewport_size.x)
	var bottom_overhang = max(0, bottom_side - viewport_size.y)
	position -= Vector2i(right_overhang, bottom_overhang)
