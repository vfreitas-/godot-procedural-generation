tool
extends MeshInstance
class_name PlanetMeshFace

export var normal: Vector3

func _ready():
	pass
	
func regenerate_mesh(planet_data: PlanetData):
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	
	var vertex_array := PoolVector3Array()
	var uv_array := PoolVector2Array()
	var normal_array := PoolVector3Array()
	var index_array := PoolIntArray()
	
	var resolution := planet_data.resolution
	var num_vertices := resolution * resolution
	var num_indices := (resolution -1) * (resolution -1) * 6
	
	normal_array.resize(num_vertices)
	uv_array.resize(num_vertices)
	vertex_array.resize(num_vertices)
	index_array.resize(num_indices)
	
	var tri_index := 0
	var axis_a := Vector3(normal.y, normal.z, normal.x)
	var axis_b := normal.cross(axis_a) 
 
	for y in range(resolution):
		for x in range(resolution):
			var i := x + y * resolution
			var percent := Vector2(x, y) / (resolution -1)
			var pointOnUnitCube := normal + (percent.x - 0.5) * 2.0 * axis_a + (percent.y - 0.5) * 2.0 * axis_b
			var pointOnUnitSphere := pointOnUnitCube.normalized()
			var point_on_planet := planet_data.point_on_planet(pointOnUnitSphere)
			vertex_array[i] = point_on_planet
			
			var l = point_on_planet.length()
			if l < planet_data.min_height:
				planet_data.min_height = l
			if l > planet_data.max_height:
				planet_data.max_height = l
			
			if x != resolution - 1 and y != resolution - 1:
				index_array[tri_index + 2] = i
				index_array[tri_index + 1] = i + resolution + 1
				index_array[tri_index] = i + resolution
				
				index_array[tri_index + 5] = i
				index_array[tri_index + 4] = i + 1
				index_array[tri_index + 3] = i + resolution + 1
				tri_index += 6

	for a in range(0, index_array.size(), 3):
		var b := a + 1
		var c := a + 2
		var ab := vertex_array[index_array[b]] - vertex_array[index_array[a]]
		var bc := vertex_array[index_array[c]] - vertex_array[index_array[b]]
		var ca := vertex_array[index_array[a]] - vertex_array[index_array[c]]
		var cross_ab_bc := ab.cross(bc) * -1.0
		var cross_bc_ca := bc.cross(ca) * -1.0
		var cross_ca_ab := ca.cross(ab) * -1.0
		normal_array[index_array[a]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
		normal_array[index_array[b]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
		normal_array[index_array[c]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
	for i in range(normal_array.size()):
		normal_array[i] = normal_array[i].normalized()

	arrays[Mesh.ARRAY_VERTEX] = vertex_array
	arrays[Mesh.ARRAY_NORMAL] = normal_array
	arrays[Mesh.ARRAY_TEX_UV] = uv_array
	arrays[Mesh.ARRAY_INDEX] = index_array

	call_deferred("_update_mesh", arrays, planet_data)
	
	
func _update_mesh(arrays: Array, planet_data: PlanetData):
	var _mesh := ArrayMesh.new()
	_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	self.mesh = _mesh
	
	material_override.set_shader_param("min_height", planet_data.min_height)
	material_override.set_shader_param("max_height", planet_data.max_height)
	material_override.set_shader_param("height_color", planet_data.planet_color)
