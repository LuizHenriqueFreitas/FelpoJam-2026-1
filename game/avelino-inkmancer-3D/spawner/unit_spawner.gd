extends Node3D
class_name UnitSpawner

@export var interval: float = 5.0
@export var unit_pool: Array[PackedScene] = []

const MIN_DIST_SQ: float = 128.0 * 128.0
const MAX_DIST_SQ: float = 256.0 * 256.0

var _last_spawn_time: float = 0.0

func _ready():
	add_to_group("spawner")

func try_spawn(player: Node3D, current_time: float) -> void:
	if unit_pool.is_empty():
		return
	
	# Verifica intervalo
	if current_time - _last_spawn_time < interval:
		return
	
	# Verifica distância (usando squared para evitar sqrt)
	var dist_sq := global_position.distance_squared_to(player.global_position)
	if dist_sq < MIN_DIST_SQ or dist_sq > MAX_DIST_SQ:
		return
	
	_spawn_unit()
	_last_spawn_time = current_time


func _spawn_unit() -> void:
	var scene: PackedScene = unit_pool.pick_random()
	var unit: Node3D = scene.instantiate()
	
	get_tree().current_scene.add_child(unit)
	unit.global_position = global_position
