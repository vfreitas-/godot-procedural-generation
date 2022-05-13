tool
extends Node
class_name BSPTree

enum Tiles { GROUND, TREE, WATER, ROOF }

var tree = {}
var leaves = []
var leaf_id = 0
var rooms = []

func generate():
	clear()
	fill_roof()
	start_tree()
	create_leaf(0)
	create_rooms()
	join_rooms()
	clear_deadends()

func fill_roof():
	for x in range(0, map_w):
		for y in range(0, map_h):
			set_cell(x, y, Tiles.ROOF)

func start_tree():
	rooms = []
	tree = {}
	leaves = []
	leaf_id = 0

	tree[leaf_id] = { "x": 1, "y": 1, "w": map_w-2, "h": map_h-2 }
	leaf_id += 1
