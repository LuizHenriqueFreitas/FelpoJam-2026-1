extends CanvasLayer

@onready var pocao_vida_liquido = $HUDRoot/VidaSection/PocaoLiquido
@onready var pocao_mana_liquido = $HUDRoot/ManaSection/PocaoLiquido

@onready var vida_section = $HUDRoot/VidaSection
@onready var mana_section = $HUDRoot/ManaSection

@onready var btn_habilidade = [
	$HUDRoot/CentroSection/Habilidades/Hab0,
	$HUDRoot/CentroSection/Habilidades/Hab1,
	$HUDRoot/CentroSection/Habilidades/Hab2,
	$HUDRoot/CentroSection/Habilidades/Hab3,
]

@onready var btn_ataque    = $HUDRoot/CentroSection/AcoesExtra/BtnAtaque
@onready var btn_invocacao = $HUDRoot/CentroSection/AcoesExtra/BtnInvocacao

var habilidade_selecionada: int = 0
var vida_atual: float = 100.0
var mana_atual: float = 100.0


func _ready():
	vida_section.mouse_filter = Control.MOUSE_FILTER_STOP
	mana_section.mouse_filter = Control.MOUSE_FILTER_STOP
	vida_section.mouse_entered.connect(_on_vida_hover_enter)
	vida_section.mouse_exited.connect(_on_vida_hover_exit)
	mana_section.mouse_entered.connect(_on_mana_hover_enter)
	mana_section.mouse_exited.connect(_on_mana_hover_exit)

	# Inicializa líquido cheio
	_atualizar_liquido(pocao_vida_liquido, 100.0)
	_atualizar_liquido(pocao_mana_liquido, 100.0)

	# Botões de habilidade
	for i in btn_habilidade.size():
		var idx = i
		btn_habilidade[i].pressed.connect(func(): _selecionar_habilidade(idx))

	# Botões de ação
	btn_ataque.pressed.connect(_on_ataque)
	btn_invocacao.pressed.connect(_on_invocacao)

	# Seleciona habilidade 1 por padrão
	_selecionar_habilidade(0)



func _on_vida_hover_enter():
	vida_section.tooltip_text = "Vida: %d / 100" % int(vida_atual)

func _on_vida_hover_exit():
	vida_section.tooltip_text = ""

func _on_mana_hover_enter():
	mana_section.tooltip_text = "Mana: %d / 100" % int(mana_atual)

func _on_mana_hover_exit():
	mana_section.tooltip_text = ""



func atualizar_vida(valor: float):
	vida_atual = clamp(valor, 0, 100)
	_atualizar_liquido(pocao_vida_liquido, vida_atual)


func atualizar_mana(valor: float):
	mana_atual = clamp(valor, 0, 100)
	_atualizar_liquido(pocao_mana_liquido, mana_atual)


func _atualizar_liquido(liquido: TextureRect, percentual: float):
	var mat = liquido.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("percentual", percentual / 100.0)
	else:
		push_error("PocaoLiquido '%s' nao tem ShaderMaterial!" % liquido.name)


func _selecionar_habilidade(idx: int):
	for i in btn_habilidade.size():
		btn_habilidade[i].modulate = Color(1, 1, 1, 1)
	habilidade_selecionada = idx
	btn_habilidade[idx].modulate = Color(1.5, 1.2, 0.2, 1)



func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: _selecionar_habilidade(0)
			KEY_2: _selecionar_habilidade(1)
			KEY_3: _selecionar_habilidade(2)
			KEY_4: _selecionar_habilidade(3)

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not _mouse_sobre_hud():
				_on_ataque()



func _on_ataque():
	print("Ataque executado!")

func _on_invocacao():
	print("Invocando habilidade: ", habilidade_selecionada + 1)


func _mouse_sobre_hud():
	var mouse_pos = get_viewport().get_mouse_position()
	var hud_root = $HUDRoot
	var rect = Rect2(hud_root.global_position, hud_root.size)
	return rect.has_point(mouse_pos)
