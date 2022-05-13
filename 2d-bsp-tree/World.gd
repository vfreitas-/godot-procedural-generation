tool
extends Node2D

export(bool) var redraw = false setget set_redraw

export(int) var map_w = 80
export(int) var map_h = 50
export(int) var min_room_size = 8
export(float, 0.2, 0.5) var min_room_factor = 0.4

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum Tiles { OUTSIDE, GROUND }

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func generate_level() -> void:
	var tilemap = $TileMapWalls
	if not tilemap:
		return
	
	tilemap.clear()
	
func fill_outside(tilemap: TileMap):
	for x in range(0, map_w):
		for y in range(0, map_h):
			tilemap.set_cell(x, y, Tiles.OUTSIDE)

func set_redraw(value: bool) -> void:
	generate_level()
