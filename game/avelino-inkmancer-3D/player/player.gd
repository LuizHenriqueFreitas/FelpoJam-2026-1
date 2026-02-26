extends BaseUnit
class_name Player

var hud : CanvasLayer
	
func _ready() -> void:
	current_health = max_health
	hud = get_node("../HUD")
	add_to_group("player")
	 
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace ddasdUI actions with custom gameplay actions.
	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_front", "walk_back")
	var direction := Vector3(input_dir.x, 0, input_dir.y)
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		direction = direction.rotated(Vector3.UP, -PI / 4)
	
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)
	
	move_and_slide()
	
func take_damage(amount: float) -> void:
	if state == UnitState.DEAD:
		return
			
	current_health -= amount
		
	hud.atualizar_vida(current_health)

	if current_health <= 0.0:
		die()
	
func behavior_ai(delta):
	pass
	
func die():
	print("game over")
