tool
extends Node2D

const Player = preload("res://common/Player.tscn")
const Exit = preload("res://common/Exit.tscn")

#export(bool) var render = false setget set_render

var total_size = Rect2(0, 0, 30, 30)
var borders = Rect2(1, 1, 26, 26)

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
	var map = walker.walk(300)
	
	var player = Player.instance()
	add_child(player)
	player.position = map.front() * 32

	var exit = Exit.instance()
	add_child(exit)
	exit.position = walker.get_end_room().position * 32
	exit.connect("leaving_level", self, "reload_level")
	
	walker.queue_free()
	for location in map:
		tilemap.set_cellv(location, -1)
	tilemap.update_bitmask_region(borders.position, borders.end)

func reload_level() -> void:
	get_tree().reload_current_scene()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		reload_level()
