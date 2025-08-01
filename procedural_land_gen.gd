@tool
extends Node3D

const chunk_node: PackedScene = preload("res://procedural_land.tscn")

var camera_position: Vector3 = Vector3(0, 0, 0)

@export_category("Map settings")
@export var world_size: int = 3:
	set(new_ws):
		world_size = new_ws
		update_map()

@export_range(4, 256, 1) var lod_bias := 32:
	set(new_lod):
		lod_bias = new_lod
		update_map()

@export var biome_noise: FastNoiseLite

@export_category("Chunk settings")
@export var noise: FastNoiseLite:
	set(new_noise):
		noise = new_noise
		update_map()
		
@export_range(4.0, 128.0, 4.0) var height := 64.0:
	set(new_height):
		height = new_height
		update_map()

@export_range(4, 256, 4) var max_resolution := 32:
	set(new_resolution):
		max_resolution = new_resolution
		update_map()

@export var material: Material = preload("res://procedural_land.tres")
@export var generate_collision_mesh: bool = true
@export var generate_lods: bool = true

func _ready() -> void:
	update_map()

func update_map() -> void:
	var children: Array[Node] = get_children()
	var tmp_name: String = ""
	var tmp_found: bool = false
	var tmp_world_size: int = 2 * world_size - 1
	var tmp_id: int = -(tmp_world_size * tmp_world_size) / 2.0
	var new_noise_res: FastNoiseLite = FastNoiseLite.new()
	var tmp_pos: Vector2i = Vector2i(0, 0)
	var tmp_rm_id: int = 0
	for chunk in children:
		if chunk.name.begins_with("chunk_"):
			tmp_rm_id = int(chunk.name.trim_prefix("chunk_"))
			if tmp_rm_id < tmp_id:
				chunk.queue_free()
			elif tmp_rm_id > -tmp_id:
				chunk.queue_free()
	for x in range(tmp_world_size):
		for y in range(tmp_world_size):
			tmp_pos = Vector2i(int(x - (world_size-1)) * 256,  int(y - (world_size-1)) * 256)
			tmp_name = "chunk_"+str(tmp_id)
			tmp_found = false
			for child in children:
				if child.name == tmp_name:
					tmp_found = true
					child.position = Vector3(tmp_pos.x, 0, tmp_pos.y)
					child.noise.offset = Vector3(tmp_pos.x, tmp_pos.y, 0)
					child.update_mesh()

			if not tmp_found:
				var new_chunk: Node = chunk_node.instantiate()
				new_chunk.name = tmp_name
				new_chunk.position = Vector3(tmp_pos.x, 0, tmp_pos.y)
				new_chunk.noise.offset = Vector3(tmp_pos.x, tmp_pos.y, 0)
				new_chunk.update_mesh()
				add_child(new_chunk)
			tmp_id += 1
