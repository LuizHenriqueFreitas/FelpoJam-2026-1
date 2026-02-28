extends SiegeUnit
class_name SiegeAlly

@export var player_min_distance: float = 20.0

var player: Node3D

func _ready():
	super._ready()
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	match state:
		UnitState.MOVING:
			get_node("canhaoMinion/AnimationPlayer").play("canhao_001")
<<<<<<< HEAD
		UnitState.CHASING:
			get_node("canhaoMinion/AnimationPlayer").play("canhao_001")
=======
			get_node("canhaoMinion/AnimationPlayer").play("canhao_002")
			get_node("canhaoMinion/AnimationPlayer").play("canhao_003")
			get_node("canhaoMinion/AnimationPlayer").play("canhao_004")
			get_node("AudioAndar").play()
		UnitState.CHASING:
			get_node("canhaoMinion/AnimationPlayer").play("canhao_001")
			get_node("canhaoMinion/AnimationPlayer").play("canhao_002")
			get_node("canhaoMinion/AnimationPlayer").play("canhao_003")
			get_node("canhaoMinion/AnimationPlayer").play("canhao_004")
			get_node("AudioAndar").play()
		UnitState.ATTACKING:
			get_node("AudioTiro").play()
>>>>>>> d4aff0fc3f74e00bf2f53cc9e085e1ab66b1cbff
		UnitState.DEAD:
			queue_free()

func behavior_ai(delta):

	if state == UnitState.DEAD:
		return

	var enemies = get_valid_enemies()

	if player != null and not detection_area.get_overlapping_bodies().has(player):
		move_to(player.global_position)
		return

	if enemies.size() > 0:
		target = get_enemy_closest_to_player(enemies)

<<<<<<< HEAD
		var dist_to_player = global_position.distance_to(player.global_position)

		if dist_to_player > player_min_distance:
			move_to(player.global_position)
			return

		if state != UnitState.ATTACKING:
			chase(target)
		return

	state = UnitState.IDLE


func get_valid_enemies() -> Array[BaseUnit]:
	var result: Array[BaseUnit] = []

	for unit in detected_units:
		if unit != null and unit.state != UnitState.DEAD and unit.faction != faction:
			result.append(unit)

	return result


func get_enemy_closest_to_player(enemies: Array[BaseUnit]) -> BaseUnit:
	var closest: BaseUnit = null
	var min_distance := INF

	for unit in enemies:
		var dist = unit.global_position.distance_to(player.global_position)
		if dist < min_distance:
			min_distance = dist
			closest = unit

	return closest
=======
	if chosen != null:
		chase(chosen)
	else:
		state = UnitState.IDLE

func process_attack():
	get_node("AudioTiro").play()
	super.process_attack()
>>>>>>> d4aff0fc3f74e00bf2f53cc9e085e1ab66b1cbff
