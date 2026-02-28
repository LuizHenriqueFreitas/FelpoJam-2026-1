extends BaseUnit

@export var win_scene: PackedScene
@export var retreat_time: float = 3.0

var player: Node3D
var retreat_timer: float = 0.0
var retreated: float = 0.0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if state == UnitState.ATTACKING:
		get_node("anjo/AnimationPlayer").play("ataque")
	else:
		get_node("anjo/AnimationPlayer").play("idle")

func _ready() -> void:
	super._ready()
	player = get_tree().get_first_node_in_group("player")


func _on_damaged() -> void:
	retreat_timer = retreat_time

func behavior_ai(delta: float) -> void:
	if state == UnitState.DEAD:
		return

	if player != null and retreat_timer > 0.0 and current_health < max_health / 2.0 and retreated < retreat_time:
		retreat_timer -= delta
		retreated += delta

		var dir = (global_position - player.global_position).normalized()
		move_to(global_position + dir * 3.0)
		return

	var enemies = get_valid_enemies()
	if enemies.size() > 0:
		target = get_closest_enemy(enemies)
		if state != UnitState.ATTACKING:
			chase(target)
		return

	if player != null:
		move_to(player.global_position)


func attack(enemy: BaseUnit) -> void:
	if enemy == null:
		return

	rotate_towards(enemy.global_position)
	enemy.take_damage(damage)


func get_valid_enemies() -> Array[BaseUnit]:
	var result: Array[BaseUnit] = []
	for unit in get_tree().get_nodes_in_group("base_unit"):
		if unit == self:
			continue
		if not (unit is BaseUnit):
			continue
		if unit.state == UnitState.DEAD:
			continue
		if unit.faction == faction:
			continue
		result.append(unit)
	return result


func get_closest_enemy(enemies: Array[BaseUnit]) -> BaseUnit:
	var closest: BaseUnit = null
	var min_distance := INF

	for unit in enemies:
		var dist = global_position.distance_to(unit.global_position)
		if dist < min_distance:
			min_distance = dist
			closest = unit

	return closest
		
func die():
	var WIN_SCENE = win_scene.instantiate()
	get_tree().root.add_child(WIN_SCENE)
	super.die()
