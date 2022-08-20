extends Object
class_name Numbers

const UNITS = ['/s', '/m', '/h', '/d', '/w']
const UNIT_MULTIPLIER = [1, 60, 60, 24, 7]

static func format_rate(rate:float) -> String:
	if rate == 0:
		return '0/s'
	var units = 0
	while rate < 0.1 and units < UNITS.size() - 1:
		units += 1
		rate *= UNIT_MULTIPLIER[units]
	while rate >= 100 and units > 0:
		units -= 1
		rate /= UNIT_MULTIPLIER[units]
	var result = format_number(rate)
	if rate > 0:
		result = '+'+result
	return result + UNITS[units]

static func format_number(val) -> String:
	var exp = 0
	if val != 0:
		while val >= 1000:
			val /= 1000
			exp += 3
		while val < 0.001:
			val *= 1000
			exp -= 3
		var result = ("%.3f" % [val]).rstrip('0').trim_suffix('.')
		if exp != 0:
			result += 'e'+str(exp)
		return result
	else:
		return '0'
