extends Object
class_name Util

# Given a non-array, returns the input value
# Given an array, chooses a random entry from the array. If the entry is an array, repeat until it's not.
static func choose_nested_option(option_tree, null_default=''):
	while option_tree is Array:
		option_tree = option_tree[randi() % option_tree.size()]
	return option_tree

# Given an array of zero or more nested option arrays (see choose_nested_option),
# generate a space-separated string generated in the same order as the option arrays
static func generate_option_string(options:Array)->String:
	var result = ''
	for option_set in options:
		var cur_option = choose_nested_option(option_set)
		if cur_option != null and cur_option != '':
			if result != '' and result[-1] != ' ': result += ' '
			result += cur_option
	return result
