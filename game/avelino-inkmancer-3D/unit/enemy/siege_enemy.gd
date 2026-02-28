extends SiegeUnit
class_name SiegeEnemy

var player: BaseUnit

func _ready():
	super._ready()
	player = get_tree().get_first_node_in_group("player")

func _procces(delta: float) -> void:
	super._process(delta)
	match state:
		UnitState.MOVING:
			get_node("canhao/AnimationPlayer").play("canhao_001")
			get_node("canhao/AnimationPlayer").play("canhao_002")
			get_node("canhao/AnimationPlayer").play("canhao_003")
			get_node("canhao/AnimationPlayer").play("canhao_004")
		UnitState.CHASING:
			get_node("canhao/AnimationPlayer").play("canhao_001")
			get_node("canhao/AnimationPlayer").play("canhao_002")
			get_node("canhao/AnimationPlayer").play("canhao_003")
			get_node("canhao/AnimationPlayer").play("canhao_004")
		UnitState.DEAD:
			queue_free()

func behavior_ai(delta):

	if player == null or state == UnitState.DEAD:
		return

	# Se já estiver atacando ou perseguindo, deixe a state machine resolver
	if state == UnitState.ATTACKING or state == UnitState.CHASING:
		return

	var chosen = get_farthest_target()

	if chosen != null:
		chase(chosen)
	else:
		move_to(player.global_position)
