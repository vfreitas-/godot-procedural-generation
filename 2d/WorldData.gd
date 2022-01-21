tool
extends Resource
class_name WorldData

export(Array, Resource) var terrains = []
export(float) var size: float
export(float) var scale: float
export(OpenSimplexNoise) var noise_map: OpenSimplexNoise
export(OpenSimplexNoise) var moisture: OpenSimplexNoise


