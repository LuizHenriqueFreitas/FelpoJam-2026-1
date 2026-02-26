extends BaseUnit
class_name MeleeUnit

var detected_units: Array[BaseUnit] = []

@onready var detection_area: Area3D = $DetectionArea

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

func attack(enemy: BaseUnit):
	if enemy == null:
		return
	
	rotate_towards(enemy.global_position)
	enemy.take_damage(damage)

func get_valid_enemies() -> Array[BaseUnit]:
	var result: Array[BaseUnit] = []
	
	for unit in detected_units:
		if unit != null and unit.state != UnitState.DEAD and unit.faction != faction:
			result.append(unit)
	
	return result
