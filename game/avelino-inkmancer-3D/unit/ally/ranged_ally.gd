extends RangedUnit
class_name RangedAlly

@export var player_min_distance: float = 20.0

var player: Node3D

func _ready():
	super._ready()
	player = get_tree().get_first_node_in_group("player")

func behavior_ai(delta: float):

	if state == UnitState.DEAD:
		return

	var enemies = get_valid_enemies()

	# PRIORIDADE 1 — Player fora da área
	if player != null and not detection_area.get_overlapping_bodies().has(player):
		move_to(player.global_position)
		return

	# PRIORIDADE 2 — Inimigos detectados
	if enemies.size() > 0:
		target = get_enemy_closest_to_player(enemies)

		var dist_to_player = global_position.distance_to(player.global_position)

		# Se estiver longe demais do player, volta até 5m
		if dist_to_player > player_min_distance:
			move_to(player.global_position)
			return

		if state != UnitState.ATTACKING:
			chase(target)
		return

	state = UnitState.IDLE
	
func get_enemy_closest_to_player(enemies: Array[BaseUnit]) -> BaseUnit:
	var closest: BaseUnit = null
	var min_distance := INF

	for unit in enemies:
		var dist = unit.global_position.distance_to(player.global_position)
		if dist < min_distance:
			min_distance = dist
			closest = unit

	return closest
