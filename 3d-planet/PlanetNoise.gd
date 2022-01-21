tool
extends Resource
class_name PlanetNoise

export var noise_map: OpenSimplexNoise
export(float) var amplitude := 1.0
export(float) var min_height := 0.0
export var use_first_layer_as_mask := false
