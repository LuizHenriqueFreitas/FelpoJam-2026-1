extends Node3D

@export var player: Node3D
@export var camera: Camera3D
@export var invocation_range: float = 10.0
@export var cursor_circle_radius: float = 0.5

var em_modo_invocacao: bool = false
var habilidade_selecionada: int = 0
var posicao_invocacao: Vector3 = Vector3.ZERO

var range_mesh: MeshInstance3D
var cursor_mesh: MeshInstance3D


func _ready():
	call_deferred("_setup_circulos")


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
	# Busca a habilidade selecionada direto da HUD(tem que mudar pra ele pegar do player)
	var hud = get_tree().root.find_child("HUD", true, false)
	if hud:
		habilidade_selecionada = hud.habilidade_selecionada
	


	print("Invocando habilidade %d em %s" % [habilidade_selecionada + 1, posicao_invocacao])


func set_habilidade(idx: int):
	habilidade_selecionada = idx
