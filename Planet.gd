tool
extends Spatial

export(bool) var redraw = false setget set_redraw
export(Resource) var planet_data

func _ready():
	regerenate_faces()
		
func set_redraw (value):
#	redraw = value
	if value:
		planet_data.min_height = 99999.0
		planet_data.max_height = 0.0
		regerenate_faces()

func regerenate_faces():
	for child in get_children():
		var face := child as PlanetMeshFace
		face.regenerate_mesh(planet_data)
