tool
extends Resource
class_name WorldData

export(Array, Resource) var terrains = []
export(float) var size: float
export(float) var scale: float
export(OpenSimplexNoise) var elevation_noise: OpenSimplexNoise
export(OpenSimplexNoise) var moisture_noise: OpenSimplexNoise


