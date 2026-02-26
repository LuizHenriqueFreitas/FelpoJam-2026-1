extends BaseUnit
class_name SiegeUnit

@export var projectile_scene: PackedScene
@export var projectile_arc_time: float = 0.6
@export var projectile_offset_distance: float = 1.0

@onready var attack_origin: Node3D = $AttackOrigin
@onready var detection_area: Area3D = $DetectionArea

var detected_units: Array[BaseUnit] = []

func _ready():
	super._ready()
	detection_area.body_entered.connect(_on_detection_entered)
	detection_area.body_exited.connect(_on_detection_exited)

func attack(enemy: BaseUnit):

	if enemy == null or projectile_scene == null:
		return

	rotate_towards(enemy.global_position)

	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)

	var start_pos = attack_origin.global_position

	# DIREÇÃO atacante → alvo
	var dir = (enemy.global_position - global_position).normalized()

	# PONTO FINAL = X metros atrás do alvo
	var target_point = enemy.global_position + dir * projectile_offset_distance

	projectile.arc_time = projectile_arc_time
	projectile.initialize(start_pos, target_point, damage, faction)

func _on_detection_entered(body):
	if body is BaseUnit and body.faction != faction:
		detected_units.append(body)

func _on_detection_exited(body):
	if body is BaseUnit:
		detected_units.erase(body)

func clean_detected():
	detected_units = detected_units.filter(
		func(u): return u != null and u.state != UnitState.DEAD
	)

func get_farthest_target() -> BaseUnit:

	clean_detected()

	if detected_units.is_empty():
		return null

	var farthest = detected_units[0]
	var max_dist = global_position.distance_to(farthest.global_position)

	for unit in detected_units:
		var d = global_position.distance_to(unit.global_position)
		if d > max_dist:
			max_dist = d
			farthest = unit

	return farthest
