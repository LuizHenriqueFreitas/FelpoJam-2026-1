extends Node3D

const MELEE_ALLY_SCENE := preload("res://unit/ally/melee_ally.tscn")
const RANGED_ALLY_SCENE := preload("res://unit/ally/ranged_ally.tscn")
const SIEGE_ALLY_SCENE := preload("res://unit/ally/siege_ally.tscn")

@export var player: BaseUnit
@export var camera: Camera3D
@export var invocation_range: float = 10.0
@export var cursor_circle_radius: float = 0.5
@export var common_mana_cost: float = 30.0
@export var uncommon_mana_cost: float = 50.0
@export var rare_mana_cost: float = 80.0

var em_modo_invocacao: bool = false
var habilidade_selecionada: int = 0
var posicao_invocacao: Vector3 = Vector3.ZERO

var range_mesh: MeshInstance3D
var cursor_mesh: MeshInstance3D

var button_manager: Node
var hud


func _ready():
	call_deferred("_setup_circulos")
	button_manager = get_node("../ButtonManager")
	var hud = get_tree().root.find_child("HUD", true, false)


func _setup_circulos():
	range_mesh = MeshInstance3D.new()
	range_mesh.mesh = _gerar_circulo_mesh(invocation_range, 64)
	range_mesh.material_override = _criar_material(Color(0.0, 0.0, 0.001, 0.416))
	range_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	range_mesh.visible = false
	get_tree().current_scene.add_child(range_mesh)

	cursor_mesh = MeshInstance3D.new()
	cursor_mesh.mesh = _gerar_circulo_mesh(cursor_circle_radius, 32)
	cursor_mesh.material_override = _criar_material(Color(1.0, 0.8, 0.2, 0.5))
	cursor_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	cursor_mesh.visible = false
	get_tree().current_scene.add_child(cursor_mesh)


# Gera um círculo preenchido como ArrayMesh no plano XZ
func _gerar_circulo_mesh(raio: float, segmentos: int) -> ArrayMesh:
	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()

	# Centro
	vertices.append(Vector3(0, 0, 0))

	# Vértices da borda
	for i in range(segmentos):
		var angulo = (float(i) / float(segmentos)) * TAU
		vertices.append(Vector3(cos(angulo) * raio, 0, sin(angulo) * raio))

	# Triângulos (leque a partir do centro)
	for i in range(segmentos):
		indices.append(0)
		indices.append(i + 1)
		indices.append((i + 1) % segmentos + 1)

	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices

	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func _criar_material(cor: Color) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = cor
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.no_depth_test = true
	return mat


func _process(_delta):
	if not em_modo_invocacao or player == null or camera == null:
		return
	if range_mesh == null or cursor_mesh == null:
		return

	# Círculo de range segue o player
	range_mesh.global_position = player.global_position + Vector3(0, 0.05, 0)

	# Posição do mouse no mundo
	var pos_mouse = _get_mouse_world_position()
	if pos_mouse == Vector3.ZERO:
		return

	# Limita dentro da range
	var diff = Vector3(
		pos_mouse.x - player.global_position.x,
		0,
		pos_mouse.z - player.global_position.z
	)
	if diff.length() > invocation_range:
		diff = diff.normalized() * invocation_range

	posicao_invocacao = player.global_position + diff
	cursor_mesh.global_position = posicao_invocacao + Vector3(0, 0.06, 0)


func _input(event):
	if not (event is InputEventMouseButton and event.pressed):
		return
	if event.button_index != MOUSE_BUTTON_RIGHT:
		return

	if not em_modo_invocacao:
		_entrar_modo_invocacao()
	else:
		_invocar()
		_sair_modo_invocacao()


func _entrar_modo_invocacao():
	print("Modo de invocação: ATIVO — clique direito novamente para invocar")
	em_modo_invocacao = true
	range_mesh.global_position = player.global_position + Vector3(0, 0.05, 0)
	range_mesh.visible = true
	cursor_mesh.visible = true


func _sair_modo_invocacao():
	em_modo_invocacao = false
	if range_mesh:
		range_mesh.visible = false
	if cursor_mesh:
		cursor_mesh.visible = false


func _get_mouse_world_position() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var origem = camera.project_ray_origin(mouse_pos)
	var direcao = camera.project_ray_normal(mouse_pos)

	var plano = Plane(Vector3.UP, player.global_position.y)
	var intersecao = plano.intersects_ray(origem, direcao)

	if intersecao == null:
		return Vector3.ZERO
	return intersecao


func _invocar():
	if player == null:
		return

	if hud:
		habilidade_selecionada = hud.habilidade_selecionada

	if button_manager == null:
		push_warning("ButtonManager não encontrado para invocação.")
		return

	var selected_slot: int = button_manager.slot_selected
	if selected_slot < 0:
		push_warning("Nenhum slot selecionado para invocar.")
		return

	if selected_slot >= player.list_of_carimbos.size():
		push_warning("Slot selecionado não possui carimbo.")
		return

	var carimbo_data: Dictionary = player.list_of_carimbos[selected_slot]
	if carimbo_data.is_empty():
		push_warning("Carimbo inválido no slot selecionado.")
		return

	var carimbo_rarity: int = int(carimbo_data.get("rarity", Carimbo.Raridade.COMUM))
	if button_manager.is_slot_on_cooldown(selected_slot):
		var remaining_cd: float = button_manager.get_slot_cooldown_remaining(selected_slot)
		print("Slot em cooldown: %.1fs" % remaining_cd)
		return

	var mana_cost: float = _get_mana_cost_by_rarity(carimbo_rarity)
	if player.current_mana < mana_cost:
		print("Mana insuficiente para invocar. Necessário: %.0f" % mana_cost)
		return

	if not carimbo_data.has("unit_type"):
		push_warning("Carimbo sem unit_type.")
		return

	var unit_scene: PackedScene
	match carimbo_data["unit_type"]:
		Carimbo.TipoUnidade.GUERREIRO:
			unit_scene = MELEE_ALLY_SCENE
		Carimbo.TipoUnidade.ARQUEIRO:
			unit_scene = RANGED_ALLY_SCENE
		Carimbo.TipoUnidade.CANHAO:
			unit_scene = SIEGE_ALLY_SCENE
		_:
			push_warning("Tipo de unidade desconhecido no carimbo.")
			return

	var unit_instance := unit_scene.instantiate() as BaseUnit
	if unit_instance == null:
		push_warning("Falha ao instanciar unidade da invocação.")
		return

	var attack_points: int = int(carimbo_data.get("unit_attack", 0))
	var hp_points: int = int(carimbo_data.get("unit_hp", 0))
	var ms_points: int = int(carimbo_data.get("unit_ms", 0))

	var attack_multiplier: float = pow(1.2, attack_points)
	var hp_multiplier: float = pow(1.2, hp_points)
	var ms_multiplier: float = pow(1.2, ms_points)

	unit_instance.damage *= attack_multiplier
	unit_instance.max_health *= hp_multiplier
	unit_instance.move_speed *= ms_multiplier
	unit_instance.faction = BaseUnit.Faction.ALLY

	get_tree().current_scene.add_child(unit_instance)
	unit_instance.global_position = posicao_invocacao
	player.spend_mana(mana_cost)

	var cooldown_duration: float = _get_cooldown_by_rarity(carimbo_rarity)
	button_manager.start_slot_cooldown(selected_slot, cooldown_duration)


func _get_cooldown_by_rarity(rarity: int) -> float:
	match rarity:
		Carimbo.Raridade.COMUM:
			return 10.0
		Carimbo.Raridade.INCOMUM:
			return 14.0
		Carimbo.Raridade.RARO:
			return 20.0
		_:
			return 10.0


func _get_mana_cost_by_rarity(rarity: int) -> float:
	match rarity:
		Carimbo.Raridade.COMUM:
			return common_mana_cost
		Carimbo.Raridade.INCOMUM:
			return uncommon_mana_cost
		Carimbo.Raridade.RARO:
			return rare_mana_cost
		_:
			return common_mana_cost


func set_habilidade(idx: int):
	habilidade_selecionada = idx
