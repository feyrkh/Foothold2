extends GameItem

signal stability_updated(game_item)

var stability := 0.0:
	set(val):
		if val != stability:
			stability = val
			self.description_updated.emit(self)
			self.stability_updated.emit(self)
var vis_accumulated := 0.0:
	set(val):
		if val != vis_accumulated:
			vis_accumulated = val
			self.description_updated.emit(self)
			self.stability_updated.emit(self)

var vis_suppliers = []

func get_ignore_field_names() -> Dictionary:
	var result = {'vis_suppliers':true}
	result.merge(super.get_ignore_field_names())
	return result

func _ready():
	super._ready()
	Events.game_tick.connect(on_game_tick)
	contents_updated.connect(on_contents_updated)
	on_contents_updated()

func on_game_tick():
	Vis.equalize_vis_with_all_suppliers(vis_suppliers, self)

func get_stability()->float:
	return stability

func get_vis()->float:
	return vis_accumulated

func get_vis_type()->int:
	return Vis.TYPE_IMPURE

func receive_vis(vis_type:int, vis_amt: float):
	vis_accumulated += vis_amt
	while vis_accumulated > stability:
		vis_accumulated -= (stability + 0.1)
		stability += 0.1

func on_contents_updated():
	vis_suppliers = find_child_items(func(game_item): return game_item and game_item.get_tags().has(Tags.TAG_VIS_SUPPLIER))

const SELF_TAGS = {}
const ALLOWED_TAGS = {Tags.TAG_VIS_SUPPLIER:true}
func get_tags()->Dictionary:
	return SELF_TAGS

func get_allowed_tags()->Dictionary:
	return ALLOWED_TAGS

func get_action_panel_scene_path()->String:
	return "res://items/FlexibleItemActions.tscn"

const ACTION_SECTIONS = ['Description', 'Stability']
func get_action_sections()->Array:
	return ACTION_SECTIONS

func get_description():
	if stability <= 0:
		return 'The portal arch is filled with blank stone, glowing gently. Nothing can pass through as it is now - it must be charged first.'
	elif stability < 1.0:
		return 'A thick fog fills the arch, and nothing can be seen beyond. Muffled voices from home can be heard faintly - communication is possible, but only the smallest and least consequential of items could pass through without destabilizing the portal.'
	elif stability < 2.0:
		return 'A thick fog fills the arch, and nothing can be seen beyond. Voices from home come through softly, but clear enough to understand. Perhaps some more valuable objects might pass through into this world now.'
	elif stability < 10:
		return 'Shifting veils of mist fill the arch, dim figures can be seen just through the arch. Conversation with the portal crew from your homeworld is easy, and more significant transfers can be made.'
	else:
		return 'The portal back home is crystal clear, like looking through a window across dimensions. The portal crew waves as they prepare the next shipment.'

func get_furniture_size():
	return 3
