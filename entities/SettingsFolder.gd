extends GameItem

func _ready():
	Factory.place_item(Factory.item("Save/Load", "res://items/settings/SaveLoadItem.gd"), self)
	
