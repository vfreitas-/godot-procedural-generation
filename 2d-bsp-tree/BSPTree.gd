tool
extends Node
class_name BSPTree

enum Tiles { GROUND, TREE, WATER, ROOF }

var bounds = Rect2()
var min_room_size = 0
var min_room_factor = 0.0

var tree = {}
var leaves = []
var leaf_id = 0
var rooms = []
# array of Rect2
var connections = []

func _init(
	_bounds: Rect2,
	_min_room_size: int,
	_min_room_factor: float
):
	bounds = _bounds
	min_room_size = _min_room_size
	min_room_factor = _min_room_factor

func generate():
	start_tree()
	create_leaf(0)
	create_rooms()
	join_rooms()
#	clear_deadends()

func start_tree():
	rooms = []
	connections = []
	tree = {}
	leaves = []
	leaf_id = 0

	tree[leaf_id] = {
		x = bounds.position.x,
		y = bounds.position.y,
		w = bounds.size.x,
		h = bounds.size.y,
	}
	leaf_id += 1

func create_leaf(parent_id):
	var x = tree[parent_id].x
	var y = tree[parent_id].y
	var w = tree[parent_id].w
	var h = tree[parent_id].h

	# used to connect the leaves later
	tree[parent_id].center = { x = floor(x + w/2), y = floor(y + h/2) }

	# whether the tree has space for a split
	var can_split = false

	# randomly split horizontal or vertical
	# if not enough width, split horizontal
	# if not enough height, split vertical
	var split_type = Util.choose(["h", "v"])
	if   (min_room_factor * w < min_room_size):  split_type = "h"
	elif (min_room_factor * h < min_room_size):  split_type = "v"

	var leaf1 = {}
	var leaf2 = {}

	# try and split the current leaf,
	# if the room will fit
	if (split_type == "v"):
		var room_size = min_room_factor * w
		if (room_size >= min_room_size):
			var w1 = Util.randi_range(room_size, (w - room_size))
			var w2 = w - w1
			leaf1 = { x = x, y = y, w = w1, h = h, split = 'v' }
			leaf2 = { x = x+w1, y = y, w = w2, h = h, split = 'v' }
			can_split = true
	else:
		var room_size = min_room_factor * h
		if (room_size >= min_room_size):
			var h1 = Util.randi_range(room_size, (h - room_size))
			var h2 = h - h1
			leaf1 = { x = x, y = y, w = w, h = h1, split = 'h' }
			leaf2 = { x = x, y = y+h1, w = w, h = h2, split = 'h' }
			can_split = true

	# rooms fit, lets split
	if (can_split):
		leaf1.parent_id    = parent_id
		tree[leaf_id]      = leaf1
		tree[parent_id].l  = leaf_id
		leaf_id += 1

		leaf2.parent_id    = parent_id
		tree[leaf_id]      = leaf2
		tree[parent_id].r  = leaf_id
		leaf_id += 1

		# append these leaves as branches from the parent
		leaves.append([tree[parent_id].l, tree[parent_id].r])

		# try and create more leaves
		create_leaf(tree[parent_id].l)
		create_leaf(tree[parent_id].r)

func create_rooms():
	for leaf_id in tree:
		var leaf = tree[leaf_id]
		if leaf.has("l"): continue # if node has children, don't build rooms

		if Util.chance(75):
			var room = {}
			room.id = leaf_id;
			room.w  = Util.randi_range(min_room_size, leaf.w) - 1
			room.h  = Util.randi_range(min_room_size, leaf.h) - 1
			room.x  = leaf.x + floor((leaf.w-room.w)/2) + 1
			room.y  = leaf.y + floor((leaf.h-room.h)/2) + 1
			room.split = leaf.split

			room.center = Vector2()
			room.center.x = floor(room.x + room.w/2)
			room.center.y = floor(room.y + room.h/2)
			rooms.append(room)

func join_rooms():
	for sister in leaves:
		var a = sister[0]
		var b = sister[1]
		connect_leaves(tree[a], tree[b])

func connect_leaves(leaf1, leaf2):
	var x = min(leaf1.center.x, leaf2.center.x)
	var y = min(leaf1.center.y, leaf2.center.y)
	var w = 1
	var h = 1

	# Vertical corridor
	if (leaf1.split == 'h'):
		x -= floor(w/2)+1
		h = abs(leaf1.center.y - leaf2.center.y)
	else:
		# Horizontal corridor
		y -= floor(h/2)+1
		w = abs(leaf1.center.x - leaf2.center.x)

	# Ensure within map
	x = 0 if (x < 0) else x
	y = 0 if (y < 0) else y

	connections.append(Rect2(x, y, w, h))
