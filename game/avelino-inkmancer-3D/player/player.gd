extends BaseUnit
class_name Player

@onready var anim_tree: AnimationTree = $mago/AnimationTree
@onready var anim_player: AnimationPlayer = $mago/AnimationPlayer

var hud : CanvasLayer
	
func _ready() -> void:
	current_health = max_health
	hud = get_node("../HUD")
	add_to_group("player")
	ArrowManager.player = self
	
	anim_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "stamp_attack-Armature_001":
		if state != UnitState.DEAD:
			state = UnitState.IDLE
	
func _physics_process(delta: float) -> void:
	
	var root_motion = anim_tree.get_root_motion_position()
	
	match state:
		UnitState.MOVING:
			get_node("mago/AnimationPlayer").play("walk-Armature_001")
		UnitState.DEAD:
			get_node("mago/AnimationPlayer").play("morte")
		UnitState.ATTACKING:
			if anim_player.current_animation != "stamp_attack-Armature_001":
				anim_player.play("stamp_attack-Armature_001")
			#tentando arrumar a animação de ataque
			velocity.x = root_motion.x / delta
			velocity.z = root_motion.z / delta
		UnitState.IDLE:
			get_node("mago/AnimationPlayer").play("idle-Armature_001")
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace ddasdUI actions with custom gameplay actions.
	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_front", "walk_back")
	var direction := Vector3(input_dir.x, 0, input_dir.y)
	
	if state != UnitState.ATTACKING and state != UnitState.DEAD:
		if direction != Vector3.ZERO:
			state = UnitState.MOVING
			direction = direction.normalized()
			direction = direction.rotated(Vector3.UP, -PI / 4)
		
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed
		else:
			state = UnitState.IDLE
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
		
	if Input.is_action_just_pressed("summon"):
		if state != UnitState.ATTACKING and state != UnitState.DEAD:
			state = UnitState.ATTACKING
			velocity.x = root_motion.x / delta
			velocity.y = root_motion.y / delta
	
	if direction.length() > 0:
		direction = direction.normalized()
		var angle = atan2(direction.x, direction.z)
		rotation.y = angle
	
	move_and_slide()
	
func take_damage(amount: float) -> void:
	if state == UnitState.DEAD:
		return
			
	current_health -= amount
		
	hud.atualizar_vida(current_health)

	if current_health <= 0.0:
		get_node("mago/AnimationPlayer").play("morte")
		
		die()
	
func behavior_ai(delta):
	pass
	
func die():
	get_tree().quit()
