extends CharacterBody3D


const SPEED = 20.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# essa é a linha que chama as animações
	# copie e cole ela para momentos que a animação muda
	# nome das animações disponiveis documentado no change log
	get_node("mago/AnimationPlayer").play("idle-Armature_001")


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace ddasdUI actions with custom gameplay actions.
	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_front", "walk_back")
	var direction := Vector3(input_dir.x, 0, input_dir.y)

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		direction = direction.rotated(Vector3.UP, -PI / 4)

		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
