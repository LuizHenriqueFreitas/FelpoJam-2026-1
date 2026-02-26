extends BaseUnit
class_name RangedUnit

@export var projectile_scene: PackedScene
@export var projectile_arc_time: float = 0.8
@export var projectile_offset_distance: float = 5.0

@onready var attack_origin: Node3D = $AttackOrigin
@onready var detection_area: Area3D = $DetectionArea

var detected_units: Array[BaseUnit] = []

func _ready():
	super._ready()
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body is BaseUnit and body != self:
		detected_units.append(body)

func _on_body_exited(body):
	if body is BaseUnit:
		detected_units.erase(body)

func get_valid_enemies() -> Array[BaseUnit]:
	var result: Array[BaseUnit] = []

	for unit in detected_units:
		if unit != null and unit.state != UnitState.DEAD and unit.faction != faction:
			result.append(unit)

	return result
	
func attack(enemy: BaseUnit) -> void:
	if projectile_scene == null:
		return

	var projectile = projectile_scene.instantiate()

	get_tree().current_scene.add_child(projectile)

	var start_pos = attack_origin.global_position

	# DIREÇÃO atacante → alvo
	var dir = (enemy.global_position - global_position).normalized()

	# PONTO FINAL = 5m atrás do alvo
	var target_point = enemy.global_position + dir * projectile_offset_distance

	projectile.arc_time = projectile_arc_time
	projectile.initialize(start_pos, target_point, damage, faction)
