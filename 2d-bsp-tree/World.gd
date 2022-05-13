tool
extends Node2D

export(bool) var redraw = false setget set_redraw

export(Rect2) var map_bounds = Rect2(1, 1, 80, 50)
export(int) var map_w = 80
export(int) var map_h = 50
export(int) var min_room_size = 8
export(float, 0.2, 0.5) var min_room_factor = 0.4

enum Tiles { OUTSIDE, GROUND }

var tilemap = null

func generate_level() -> void:
	tilemap = $TileMapWalls
	if not tilemap:
		return

	var bsp_tree = BSPTree.new(
		Rect2(map_bounds.position, Vector2(map_bounds.size.x - 2, map_bounds.size.y -2)),
		min_room_size,
		min_room_factor
	)
	
	bsp_tree.generate()

	tilemap.clear()
	fill_outside()
	fill_rooms(bsp_tree.rooms)
	fill_rooms_connections(bsp_tree.connections)
	clear_deadends()
	tilemap.update_bitmask_region(Vector2.ZERO, Vector2(map_w, map_h))
	
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

func set_redraw(_value: bool) -> void:
	generate_level()
