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

const SPECIAL_PLURALS = {
	'mouse': 'mice',
	'foot': 'feet',
	'ox': 'oxen',
}

static func pluralize(word:String, num:int) -> String:
	if num == 1:
		return word
	else:
		var lc_word = word.to_lower()
		if SPECIAL_PLURALS.has(lc_word):
			if lc_word[0] == word[0]: # same casing
				return SPECIAL_PLURALS[lc_word]
			else:
				return SPECIAL_PLURALS[lc_word].capitalize()
		elif word.ends_with('s'):
			return word+'es'
		elif word.ends_with('y'):
			return word+'ies'
		elif word.ends_with('f'):
			return word.substr(0, word.length()-2)+'ves'
		elif word.ends_with('fe'):
			return word.substr(0, word.length()-3)+'ves'
		else:
			return word+'s'

static func format_with_options(format:String, options:Dictionary) -> String:
	var seen_before = {}
	var chunks = format.split(' ')
	for i in range(chunks.size()):
		var chunk = chunks[i]
		if !chunk.begins_with('$'):
			continue
		var tries = 10
		var chosen = null
		while chosen == null and tries > 0:
			tries -= 1
			if chunk.length() > 2 and chunk[-1] == 's':
				var opts = options.get(chunk.trim_suffix('s'), chunk)
				chosen = pluralize(choose_nested_option(opts), 2)
			else:
				var opts = options.get(chunk, chunk)
				chosen = choose_nested_option(opts)
			if seen_before.has(chosen):
				chosen = null
				continue
			chunks[i] = chosen
	return ' '.join(chunks)
