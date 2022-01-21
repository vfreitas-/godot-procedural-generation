tool
extends Resource
class_name PlanetData

export var radius := 1.0
export var resolution := 10
export(Array, Resource) var planet_noise
export var planet_color: GradientTexture

var min_height := 99999.0
var max_height := 0.0

func point_on_planet(point_on_sphere: Vector3) -> Vector3:
	var elevation := 0.0
	var base_elevation := 0.0
	if planet_noise.size() > 0:
		var base_noise = planet_noise[0] as PlanetNoise
		base_elevation = base_noise.noise_map.get_noise_3dv(point_on_sphere * 100.0)
		base_elevation = base_elevation + 1 / 2.0 * base_noise.amplitude
		base_elevation = max(0.0, base_elevation - base_noise.min_height)
	
	for n in planet_noise:
		n = n as PlanetNoise
		var mask = 1.0
		
		if n.use_first_layer_as_mask:
			mask = base_elevation
		
		var level_elevation = n.noise_map.get_noise_3dv(point_on_sphere * 100.0)
		level_elevation = level_elevation + 1 / 2.0 * n.amplitude
		level_elevation = max(0.0, level_elevation - n.min_height) * mask
		elevation += level_elevation
	return point_on_sphere * radius * (elevation + 1.0)
