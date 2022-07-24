extends Node

signal game_tick()
signal add_game_item(new_game_item, parent_game_item, select_item)
signal deleting_game_item(game_item)
signal add_goal(new_goal_item)
signal pin_action_panel(tree_node, is_pinned)
signal quest_progress(quest_name, progress_arg)

signal goal_item(goal_id, item_key, item_id_not_game_item)
signal goal_data(goal_id, data_key, data_val)
signal goal_progress(goal_id, progress_data)

func safe_connect(signal_name, callable):
	if !is_connected(signal_name, callable):
		connect(signal_name, callable)
