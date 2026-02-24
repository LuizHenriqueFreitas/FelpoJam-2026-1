extends CanvasLayer

@onready var barra_vida    = $HUDRoot/HUDContainer/VidaSection/BarraVida
@onready var barra_mana    = $HUDRoot/HUDContainer/ManaSection/BarraMana
@onready var summon_system = get_node_or_null("res://SummonSystem.gd")

@onready var btn_habilidade = [
	$HUDRoot/HUDContainer/CentroSection/Habilidades/VBoxContainer/Hab1,
	$HUDRoot/HUDContainer/CentroSection/Habilidades/VBoxContainer2/Hab2,
	$HUDRoot/HUDContainer/CentroSection/Habilidades/VBoxContainer3/Hab3,
	$HUDRoot/HUDContainer/CentroSection/Habilidades/VBoxContainer4/Hab4,
]

@onready var btn_ataque    = $HUDRoot/HUDContainer/CentroSection/AcoesExtra/BtnAtaque
@onready var btn_invocacao = $HUDRoot/HUDContainer/CentroSection/AcoesExtra/BtnInvocacao

var habilidade_selecionada: int = 0
var vida_atual: float = 100.0
var mana_atual: float = 100.0


func _ready():
	barra_vida.show_percentage = false
	barra_mana.show_percentage = false

	barra_vida.mouse_entered.connect(_on_vida_hover_enter)
	barra_vida.mouse_exited.connect(_on_vida_hover_exit)

	barra_mana.mouse_entered.connect(_on_mana_hover_enter)
	barra_mana.mouse_exited.connect(_on_mana_hover_exit)

	for i in btn_habilidade.size():
		var idx = i
		btn_habilidade[i].pressed.connect(func(): _selecionar_habilidade(idx))

	# Botões de ação
	btn_ataque.pressed.connect(_on_ataque)
	btn_invocacao.pressed.connect(_on_invocacao)

	# Seleciona habilidade 1 por padrão
	_selecionar_habilidade(0)

# Hover barra de vida e tinta
func _on_vida_hover_enter():
	barra_vida.show_percentage = true

func _on_vida_hover_exit():
	barra_vida.show_percentage = false

func _on_mana_hover_enter():
	barra_mana.show_percentage = true

func _on_mana_hover_exit():
	barra_mana.show_percentage = false


# Atualização de vida e tinta
func atualizar_vida(valor: float):
	vida_atual = clamp(valor, 0, 100)
	barra_vida.value = vida_atual

func atualizar_mana(valor: float):
	mana_atual = clamp(valor, 0, 100)
	barra_mana.value = mana_atual


# Seleção de habilidade
func _selecionar_habilidade(idx: int):
	for i in btn_habilidade.size():
		btn_habilidade[i].modulate = Color(1, 1, 1, 1)
	habilidade_selecionada = idx
	btn_habilidade[idx].modulate = Color(1.5, 1.2, 0.2, 1)
	if summon_system:
		summon_system.set_habilidade(idx)


# Input por teclado e mouse
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

# Pra não conseguir atacar clicando nos botões do HUD
func _mouse_sobre_hud():
	var mouse_pos = get_viewport().get_mouse_position()
	var hud_root = $HUDRoot
	var rect = Rect2(hud_root.global_position, hud_root.size)
	return rect.has_point(mouse_pos)
