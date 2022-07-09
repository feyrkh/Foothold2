extends Tree


# Called when the node enters the scene tree for the first time.
func _ready():
	connect('multi_selected', on_multi_selected)
	if get_parent() == get_tree().root:
		var root = create_item()
		var item1 = create_item(root)
		item1.set_text(0, 'Wizard Tower')
		var item2 = create_item(item1)
		item2.set_text(0, 'Stone chamber')
		var item3 = create_item(item1)
		item3.set_text(0, 'Rooftop')
		var item4 = create_item(item2)
		item4.set_text(0, 'rubbish')
		var item5 = create_item(item2)
		item5.set_text(0, 'rubbish')
		var item6 = create_item(item2)
		item6.set_text(0, 'rubbish')

func on_multi_selected(item:TreeItem, column:int, selected:bool):
	if Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CTRL):
		var item_parent = item.get_parent()
		var cur_selected = get_next_selected(null)
		while cur_selected != null:
			if cur_selected.get_parent() != item_parent:
				item.deselect(column)
				return
			cur_selected = get_next_selected(cur_selected)
