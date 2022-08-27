extends Node

signal game_tick()
signal add_game_item(new_game_item, parent_game_item, select_item)
signal deleting_game_item(game_item)
signal add_goal(new_goal_item)
signal pin_action_panel(tree_node, is_pinned)
signal move_action_panel(action_panel, move_right)
signal quest_progress(quest_name, progress_arg)
signal drag_error_msg(msg)

signal goal_item(goal_id, item_key, item_id_not_game_item) 
signal goal_data(goal_id, data_key, data_val)
signal goal_progress(goal_id, progress_data)
signal goal_callback(goal_id, callback_fn_name, callback_arg)

signal global_save_data(data_id, data_config)
signal global_load_data(data_id, data_config)
signal trigger_save_game(save_label, save_file)
signal trigger_load_game(save_slot)
signal pre_save_game()
signal post_save_game()
signal pre_load_game()
signal post_load_game()
signal finalize_load_game()


func safe_connect(signal_name, callable):
	if !is_connected(signal_name, callable):
		connect(signal_name, callable)

static func emit_goal_progress(goal_id, progress_data):
	Events.emit_signal('goal_progress', goal_id, progress_data)
