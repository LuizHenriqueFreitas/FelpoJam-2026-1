extends BaseUnit
class_name Player

@export var max_mana: float
@export var mana_regen: float = 10
@export var list_of_carimbos: Array[Dictionary]

var current_mana: float
var time_passed: float = 0.0
var index_counter : int = 0

var hud : CanvasLayer
var button_manager: Node
	
func _ready() -> void:
	current_health = max_health
	current_mana = max_mana
	hud = get_node("../HUD")
	button_manager = get_node("../ButtonManager")
	add_to_group("player")
	ArrowManager.player = self
	 
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
		die()
	
func behavior_ai(delta):
	pass
	
func die():
	print("game over")
	
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
	
	
