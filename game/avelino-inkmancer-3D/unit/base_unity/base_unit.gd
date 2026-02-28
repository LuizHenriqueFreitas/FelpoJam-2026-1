extends CharacterBody3D
class_name BaseUnit

enum Faction { ALLY, ENEMY }
enum UnitState { IDLE, MOVING, CHASING, ATTACKING, DEAD }

@export var faction: Faction
@export var max_health: float = 100.0
@export var move_speed: float = 5.0
@export var damage: float = 10.0
@export var attack_speed: float = 1.0
@export var attack_range: float = 2.0
@export var show_health_bar: bool = true
@export var health_bar_scene: PackedScene
@export var health_bar_offset: Vector3 = Vector3(0, 2, 0)
@export var health_bar_scale: Vector3 = Vector3(1, 1, 1)

var health_bar_instance: HealthBar3D = null
var current_health: float
var state: UnitState = UnitState.IDLE
var target: BaseUnit = null
var move_target_position: Vector3
var attack_cooldown: float = 0.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	current_health = max_health
	add_to_group("base_unit")

	if show_health_bar and health_bar_scene != null:
		call_deferred("_spawn_health_bar")
	
	
func _spawn_health_bar() -> void:
	health_bar_instance = health_bar_scene.instantiate()
	get_parent().add_child(health_bar_instance)

	health_bar_instance.global_position = global_position + health_bar_offset
	health_bar_instance.scale = health_bar_scale
	health_bar_instance.setup(max_health, faction)
	
	
func _process(delta: float) -> void:
	if health_bar_instance != null:
		health_bar_instance.global_position = global_position + health_bar_offset
		health_bar_instance.rotation_degrees = Vector3(0, 135, 0)
	
	
func _physics_process(delta: float) -> void:
	if state == UnitState.DEAD:
		return
	
	update_cooldowns(delta)
	behavior_ai(delta)
	
	match state:
		UnitState.MOVING:
			process_movement()
		UnitState.CHASING:
			process_chasing()
		UnitState.ATTACKING:
			process_attack()
		UnitState.IDLE:
			velocity = Vector3.ZERO
	
	move_and_slide()
	
	
func update_cooldowns(delta: float) -> void:
	if attack_cooldown > 0.0:
		attack_cooldown -= delta
	
	
func move_to(position: Vector3) -> void:
	move_target_position = position
	target = null
	state = UnitState.MOVING
	
	
func process_movement() -> void:
	var direction: Vector3 = move_target_position - global_position
	direction.y = 0.0
	
	if direction.length() < 0.1:
		velocity = Vector3.ZERO
		state = UnitState.IDLE
		return
	
	direction = direction.normalized()
	velocity = direction * move_speed
	rotate_towards(move_target_position)
	
	
func chase(enemy: BaseUnit) -> void:
	if enemy == null or enemy.state == UnitState.DEAD:
		return
	
	target = enemy
	state = UnitState.CHASING
	
	
func process_chasing() -> void:
	if target == null or target.state == UnitState.DEAD:
		state = UnitState.IDLE
		return
	
	var direction: Vector3 = target.global_position - global_position
	direction.y = 0.0
	var distance: float = direction.length()
	
	if distance <= attack_range:
		velocity = Vector3.ZERO
		state = UnitState.ATTACKING
		return
	
	direction = direction.normalized()
	velocity = direction * move_speed
	rotate_towards(target.global_position)
	
	
func process_attack() -> void:
	if target == null or target.state == UnitState.DEAD:
		state = UnitState.IDLE
		return
	
	var distance: float = global_position.distance_to(target.global_position)
	
	if distance > attack_range:
		state = UnitState.CHASING
		return
	
	rotate_towards(target.global_position)
	
	if attack_cooldown <= 0.0:
		attack(target)
		attack_cooldown = 1.0 / attack_speed
	
	
func take_damage(amount: float) -> void:
	if state == UnitState.DEAD:
		return
	
	current_health -= amount
	
	if health_bar_instance != null:
		health_bar_instance.update_health(current_health)

	if current_health <= 0.0:
		die()
		
	_on_damaged()
		
	
	
func die() -> void:
	state = UnitState.DEAD
	velocity = Vector3.ZERO
	
	if health_bar_instance != null:
		health_bar_instance.queue_free()

	queue_free()
	
	
func rotate_towards(position: Vector3) -> void:
	var dir: Vector3 = position - global_position
	dir.y = 0.0

	if dir.length() > 0.01:
		look_at(global_position + dir, Vector3.UP)
	
	
func attack(enemy: BaseUnit) -> void:
	pass
	
	
func behavior_ai(delta: float) -> void:
	pass
	
func _on_damaged():
	pass
	
