tool
extends Node2D

#export(bool) var render = false setget set_render

var total_size = Rect2(-1, -1, 22, 13)
var borders = Rect2(1, 1, 18, 9)

onready var tilemap := $TileMap

func _ready():
	tilemap = $TileMap
	randomize()
	fill_world()
	generate_level()

func fill_world():
	for x in range(total_size.size.x):
		for y in range(total_size.size.y):
			tilemap.set_cell(x, y, 0)
	tilemap.update_bitmask_region(total_size.position, total_size.end)

func generate_level():
	var walker = Walker.new(Vector2(10, 6), borders)
	var map = walker.walk(200)
	walker.queue_free()
	for location in map:
		tilemap.set_cellv(location, -1)
	tilemap.update_bitmask_region(borders.position, borders.end)


#func set_render(value: bool) -> void:
#	tilemap = $TileMap
#	render = value
#	fill_world()
#	generate_level()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()
