tool
extends Node2D

export(bool) var redraw = false setget set_redraw

export(Rect2) var map_bounds = Rect2(1, 1, 80, 50)
export(int) var map_w = 80
export(int) var map_h = 50
export(int) var min_room_size = 8
export(float, 0.2, 0.5) var min_room_factor = 0.4

const Player = preload("res://common/Player.tscn")
const Exit = preload("res://common/Exit.tscn")

enum Tiles { OUTSIDE, GROUND }

var tilemap = null
var props = null

func _ready():
	generate_level()

func generate_level() -> void:
	tilemap = $TileMapWalls
	props = $Props
	if not tilemap:
		return

	var bsp_tree = BSPTree.new(
		Rect2(map_bounds.position, Vector2(map_bounds.size.x - 2, map_bounds.size.y -2)),
		min_room_size,
		min_room_factor
	)
	
	bsp_tree.generate()

	clear()
	fill_outside()
	fill_rooms(bsp_tree.rooms)
	fill_rooms_connections(bsp_tree.connections)
	clear_deadends()
	tilemap.update_bitmask_region(Vector2.ZERO, Vector2(map_w, map_h))
	
	render_props(bsp_tree)
	
func render_props(bsp: BSPTree) -> void:
	var player_position = bsp.rooms.front().center
	var player = Player.instance()
	props.add_child(player)
	player.position = player_position * 32
	
	var exit = Exit.instance()
	props.add_child(exit)
	var end_room = bsp.get_farthest_room_from_point(player_position)
	exit.position = end_room.center * 32
	exit.connect("leaving_level", self, "_on_leaving_level")
	
func fill_outside():
	for x in range(0, map_bounds.size.x):
		for y in range(0, map_bounds.size.y):
			tilemap.set_cell(x, y, Tiles.OUTSIDE)

func fill_rooms(rooms: Array = []):
	for i in range(rooms.size()):
		var r = rooms[i]
		for x in range(r.x, r.x + r.w):
			for y in range(r.y, r.y + r.h):
				tilemap.set_cell(x, y, Tiles.GROUND)

func fill_rooms_connections(connections: Array) -> void:
	for rect in connections:
		for i in range(rect.position.x, rect.position.x + rect.size.x):
			for j in range(rect.position.y, rect.position.y + rect.size.y):
				if(tilemap.get_cell(i, j) == Tiles.OUTSIDE): 
					tilemap.set_cell(i, j, Tiles.GROUND)

func clear_deadends():
	var done = false

	while !done:
		done = true

		for cell in tilemap.get_used_cells():
			if tilemap.get_cellv(cell) != Tiles.GROUND: continue

			var roof_count = check_nearby(cell.x, cell.y)
			if roof_count == 3:
				tilemap.set_cellv(cell, Tiles.OUTSIDE)
				done = false

# check in 4 dirs to see how many tiles are roofs
func check_nearby(x, y):
	var count = 0
	if tilemap.get_cell(x, y-1)   == Tiles.OUTSIDE:  count += 1
	if tilemap.get_cell(x, y+1)   == Tiles.OUTSIDE:  count += 1
	if tilemap.get_cell(x-1, y)   == Tiles.OUTSIDE:  count += 1
	if tilemap.get_cell(x+1, y)   == Tiles.OUTSIDE:  count += 1
	return count

func clear() -> void:
	tilemap.clear()
	for n in props.get_children():
		props.remove_child(n)
		n.queue_free()

func set_redraw(_value: bool) -> void:
	generate_level()
	
func _on_leaving_level() -> void:
	get_tree().reload_current_scene()
