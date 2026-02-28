extends MeleeUnit
class_name MeleeEnemy

var player: Node3D

func _ready():
	super._ready()
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	match state:
		UnitState.MOVING:
			get_node("guerreiro/AnimationPlayer").play("walk")
			get_node("AudioAndar").play()
		UnitState.CHASING:
			get_node("guerreiro/AnimationPlayer").play("walk")
			get_node("AudioAndar").play()
		UnitState.DEAD:
			get_node("guerreiro/AnimationPlayer").play("morte")
			queue_free()
		UnitState.ATTACKING:
			get_node("guerreiro/AnimationPlayer").play("sword_attack")
			get_node("AudioAtaque").play()
		UnitState.IDLE:
			get_node("guerreiro/AnimationPlayer").play("idle")

func behavior_ai(delta):

	if state == UnitState.DEAD:
		return

	var enemies = get_valid_enemies()

	# PRIORIDADE 1 — Ally detectado (sempre sobrepõe player)
	if enemies.size() > 0:
		'''if target != enemies[0]:
			print("[Enemy] Switching aggro to:", enemies[0].name)'''
		target = enemies[0]
		if state != UnitState.ATTACKING:
			chase(target)
		return

	# PRIORIDADE 2 — Player
	if player != null and player.state != UnitState.DEAD:
		'''if target != player:
			print("[Enemy] Chasing player")'''
		target = player
		chase(player)
