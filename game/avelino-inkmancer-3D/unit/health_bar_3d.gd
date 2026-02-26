extends Node3D
class_name HealthBar3D

@onready var background: MeshInstance3D = $Background
@onready var fill: MeshInstance3D = $Fill

var max_health: float = 100.0

func _ready() -> void:
	fill.scale.x = 1.0


func setup(max_hp: float, faction: int) -> void:
	max_health = max_hp

	if fill == null:
		push_error("Fill node não encontrado na HealthBar3D.")
		return

	var fill_material: StandardMaterial3D = StandardMaterial3D.new()
	fill_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	match faction:
		BaseUnit.Faction.ALLY:
			fill_material.albedo_color = Color(0.05, 0.15, 0.5)
		BaseUnit.Faction.ENEMY:
			fill_material.albedo_color = Color(0.8, 0.1, 0.1)

	fill.material_override = fill_material


func update_health(current_hp: float) -> void:
	var ratio: float = clamp(current_hp / max_health, 0.0, 1.0)

	fill.scale.x = ratio
	fill.position.x = (1.0 - ratio) * -0.5
