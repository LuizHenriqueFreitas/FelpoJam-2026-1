extends RangedUnit
class_name RangedEnemy

@export var retreat_time: float = 3.0
@export var retreat_speed_multiplier: float = 3

var player: Node3D
var retreat_timer: float = 0.0
var retreated: float;

func _ready():
	super._ready()
	player = get_tree().get_first_node_in_group("player")

func _on_damaged():
	retreat_timer = retreat_time

func behavior_ai(delta: float):

	if state == UnitState.DEAD:
		return

	# PRIORIDADE 3 — Retirada
			
	if retreat_timer > 0.0 && current_health < max_health/2 && retreated < retreat_time:
		retreat_timer -= delta
		retreated += delta

		var dir = (global_position - player.global_position).normalized()
		move_to(global_position + dir * 3.0)
		return

	# PRIORIDADE 2 — Atacar aliados
	var enemies = get_valid_enemies()

	if enemies.size() > 0:
		target = get_closest_enemy(enemies)

		if state != UnitState.ATTACKING:
			chase(target)
		return

	# PRIORIDADE 1 — Sempre anda para o player
	if player != null:
		move_to(player.global_position)

func get_closest_enemy(enemies: Array[BaseUnit]) -> BaseUnit:
	var closest: BaseUnit = null
	var min_distance := INF

	for unit in enemies:
		var dist = global_position.distance_to(unit.global_position)
		if dist < min_distance:
			min_distance = dist
			closest = unit

	return closest
