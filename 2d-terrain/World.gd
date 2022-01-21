tool
extends Node2D

export(bool) var redraw = false setget set_redraw
export(NodePath) var tilemap_path
export(Resource) var world_data

var tilemap: TileMap

func _ready():
	tilemap = get_node(tilemap_path)
	generate_world(world_data)


func set_redraw (value):
	tilemap = get_node(tilemap_path)
	if value:
		generate_world(world_data)
		
func generate_world(data: WorldData):
	tilemap.clear()
	
	var half_size = world_data.size / 2
	for y in range(-half_size, half_size):
		for x in range(-half_size, half_size):
			var pos := Vector2(x, y)
			
			var tile := -1
			var noise := data.noise_map.get_noise_2dv(pos * data.scale)
			
			for t in data.terrains:
				t = t as Terrain
				if noise <= t.height and tile == -1:
					tile = t.tile_id
					break
			
			tilemap.set_cell(x, y, tile, false, false, false, tilemap.get_cell_autotile_coord(x, y))
			tilemap.update_bitmask_area(pos)
