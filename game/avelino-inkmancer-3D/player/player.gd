extends BaseUnit
class_name Player

@export var max_mana: float
@export var mana_regen: float = 10
@export var list_of_carimbos: Array[Dictionary]

var current_mana: float
var time_passed: float = 0.0
var index_counter : int = 0

@onready var anim_tree: AnimationTree = $mago/AnimationTree
@onready var anim_player: AnimationPlayer = $mago/AnimationPlayer
const MORTE_SCENE = preload("res://menus/morte.tscn")

var hud : CanvasLayer
var button_manager: Node
	
func _ready() -> void:
	current_health = max_health
	current_mana = max_mana
	hud = get_node("../HUD")
	button_manager = get_node("../ButtonManager")
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
	
func _process(delta: float) -> void:
	time_passed += delta
	if time_passed >= 5.0:
		current_mana += mana_regen
		hud.atualizar_mana(current_mana)
		time_passed = 0.0
	
	super._process(delta) # Isso aqui n faz nada, pois no momento o _process de base_unit n faz nada util pro player, mas deixando só  pra caso no futuro a gente inclua algo no process do pai
	
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
	var tela = MORTE_SCENE.instantiate()
	get_tree().root.add_child(tela)
	
func spend_mana(_mana: float):
	current_mana -= _mana;
	hud.atualizar_mana(current_mana)
	
func add_carimbo(unit_type: Carimbo.TipoUnidade, unit_attack, unit_hp, unit_ms, carimbo_rarity: Carimbo.Raridade):
	list_of_carimbos.push_front(
		{
			"unit_type": unit_type,
			"unit_attack": unit_attack,
			"unit_hp": unit_hp,
			"unit_ms": unit_ms,
			"rarity": carimbo_rarity
		}
	)
	button_manager.spawn_interface(index_counter, unit_type, carimbo_rarity)
	var node_to_hide = hud.get_node_or_null("HUDRoot/CentroSection/Habilidades/Hab%d" % index_counter)
	if node_to_hide:
		node_to_hide.hide()
	index_counter += 1
