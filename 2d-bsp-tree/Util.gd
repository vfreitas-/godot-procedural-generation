extends Node
class_name Util

# Util.choose(["one", "two"])   returns one or two
static func choose(choices):
	randomize()

	var rand_index = randi() % choices.size()
	return choices[rand_index]

# the percent chance something happens
static func chance(num):
	randomize()

	if randi() % 100 <= num: return true
	else:                    return false

# returns random int between low and high
static func randi_range(low, high):
	return floor(rand_range(low, high))
