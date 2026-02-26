extends Node3D

@export var chunk_size : int = 128
@export var world_radius : int = 10   # Quantas chunk pra cada lado
@export var world_seed : int = 12345


var chunk_pool : Array = [] # Pool de chunks (definida no _ready)

var chunks : Dictionary = {} # Dicionário para armazenar chunks gerados

var rng : RandomNumberGenerator

func _ready():
	randomize_seed()
	setup_chunk_pool()
	generate_world()


func randomize_seed():
	rng = RandomNumberGenerator.new()
	world_seed = int(Time.get_unix_time_from_system())
	rng.seed = world_seed
	print("World Seed:", world_seed)


func setup_chunk_pool():
	# Cada lista é composta de: [referência a um chunk, peso na pool]

	chunk_pool = [
		[preload("res://chunks/common/common_chunk_1.tscn"), 1],
		[preload("res://chunks/common/common_chunk_2.tscn"), 5],
		[preload("res://chunks/common/common_chunk_3.tscn"), 1],
		[preload("res://chunks/common/common_chunk_4.tscn"), 1],
		[preload("res://chunks/common/common_chunk_5.tscn"), 1],
	]


func generate_world():

	# Registrar o spawn chunk como (0,0)
	chunks[Vector2i(0,0)] = self

	for x in range(-world_radius, world_radius + 1):
		for z in range(-world_radius, world_radius + 1):

			var coord = Vector2i(x, z)

			# Pula o centro (já existe)
			if coord == Vector2i(0,0):
				continue

			spawn_chunk_at(coord)


func spawn_chunk_at(coord: Vector2i):

	if chunks.has(coord):
		return

	var scene = get_weighted_chunk()
	var chunk_instance = scene.instantiate()

	add_child(chunk_instance)

	chunk_instance.position = Vector3(
		coord.x * chunk_size,
		0,
		coord.y * chunk_size
	)

	chunks[coord] = chunk_instance


func get_weighted_chunk() -> PackedScene:

	var total_weight = 0

	for entry in chunk_pool:
		total_weight += entry[1]

	var roll = rng.randi_range(1, total_weight)

	var cumulative = 0

	for entry in chunk_pool:
		cumulative += entry[1]
		if roll <= cumulative:
			return entry[0]

	# fallback
	return chunk_pool[0][0]
