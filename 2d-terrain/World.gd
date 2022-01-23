tool
extends Node2D

export(bool) var redraw = false setget set_redraw
export(NodePath) var tilemap_path
export(Resource) var world_data

var tilemap: TileMap
var last_mouse_pos := Vector2.ZERO

onready var tile_hover := $TileHover
onready var selected_tile_label := $CanvasLayer/VBox/Label

func _ready():
	tilemap = get_node(tilemap_path)
	generate_world(world_data)
	
# GoHorse code for showing the selected terrain on the UI
func _process(delta):
	if Engine.editor_hint:
		return
	var mouse_position = get_global_mouse_position()
	if last_mouse_pos != mouse_position:
		last_mouse_pos = mouse_position
		var tile_mouse_pos = tilemap.world_to_map(mouse_position)
		var selected_tile_id = tilemap.get_cellv(tile_mouse_pos)
		var selected_terrain: Terrain = null
		for t in world_data.terrains:
			t = t as Terrain
			if t.tile_id == selected_tile_id:
				selected_terrain = t
				break
				
		if selected_terrain:
			selected_tile_label.text = selected_terrain.name
		
		tile_hover.global_position = tilemap.map_to_world(tile_mouse_pos)
	


func set_redraw (value):
	tilemap = get_node(tilemap_path)
	if value:
		generate_world(world_data)
		
func generate_world(data: WorldData):
	tilemap.clear()
	
	var half_size = data.size / 2
	for y in range(0, data.size):
		for x in range(0, data.size):
			var pos := Vector2(x, y)

			var tile := -1
			var noise := data.elevation_noise.get_noise_2dv(pos * data.scale)
			var lerp_noise := range_lerp(noise, -1, 1, 0, 1)

			var nx = x / data.size - 0.5
			var ny = y / data.size - 0.5
			var d = sqrt(nx * nx + ny * ny) / sqrt(0.5)
#			print("Pos: ", pos, "; Distance: ", d)

			var lerp_x := range_lerp(x, 0, data.size, -1, 1)
			var lerp_y := range_lerp(y, 0, data.size, -1, 1)

			var e = (1 + lerp_noise - d) / 2
#			e = round(e * 12) / 12 
#			var e = lerp_noise
			
			for t in data.terrains:
				t = t as Terrain
				if e <= t.height and tile == -1:
					tile = t.tile_id
					break
			
			tilemap.set_cell(x, y, tile, false, false, false, tilemap.get_cell_autotile_coord(x, y))
			tilemap.update_bitmask_area(pos)
