extends Section

func _ready():
	get_game_item().connect('vis_updated', vis_updated)
	vis_updated(get_game_item())

func vis_updated(game_item):
	self.text = "Contains %.1f/%.1f %s vis\nInput rate: %.1f vis/sec\nOutput rate: %.1f vis/sec" % \
		[game_item.get_vis(), game_item.get_max_vis(), Vis.vis_type_name(game_item.get_vis_type()), game_item.get_vis_input_speed(), game_item.get_vis_output_speed()]
