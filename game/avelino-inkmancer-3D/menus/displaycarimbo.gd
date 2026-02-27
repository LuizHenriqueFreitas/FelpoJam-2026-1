extends Control

# ta porco, eu sei!!

signal carimbo_confirmado(carimbo: Carimbo)

@export var textura_guerreiro: Texture2D
@export var textura_arqueiro:  Texture2D
@export var textura_canhao:    Texture2D

# Bordas por raridade
@export var borda_comum:   Texture2D
@export var borda_incomum: Texture2D
@export var borda_raro:    Texture2D

# Ícones por tipo de unidade
@export var icone_guerreiro: Texture2D
@export var icone_arqueiro:  Texture2D
@export var icone_canhao:    Texture2D

@onready var label_raridade    = $Painel/MarginContainer/VBoxContainer/Cabecalho/VBoxContainer/LabelRaridade
@onready var label_pre_alocado = $Painel/MarginContainer/VBoxContainer/Cabecalho/VBoxContainer/LabelPreAlocado
@onready var label_pontos      = $Painel/MarginContainer/VBoxContainer/Cabecalho/LabelPontos
@onready var preview_gravura   = $Painel/MarginContainer/VBoxContainer/Corpo/ColunaEsquerda/PreviewGravura

@onready var barra_ataque      = $Painel/MarginContainer/VBoxContainer/Corpo/ColunaEsquerda/Atributos/LinhaAtaque/BarraAtaque
@onready var barra_vida        = $Painel/MarginContainer/VBoxContainer/Corpo/ColunaEsquerda/Atributos/LinhaVida/BarraVida
@onready var barra_velocidade  = $Painel/MarginContainer/VBoxContainer/Corpo/ColunaEsquerda/Atributos/LinhaVelocidade/BarraVelocidade

@onready var label_ataque      = $Painel/MarginContainer/VBoxContainer/Corpo/ColunaEsquerda/Atributos/LinhaAtaque/LabelAtaque
@onready var label_vida        = $Painel/MarginContainer/VBoxContainer/Corpo/ColunaEsquerda/Atributos/LinhaVida/LabelVida
@onready var label_velocidade  = $Painel/MarginContainer/VBoxContainer/Corpo/ColunaEsquerda/Atributos/LinhaVelocidade/LabelVelocidade

@onready var btn_ataque_mais   = $Painel/MarginContainer/VBoxContainer/Corpo/ColunaEsquerda/Atributos/LinhaAtaque/BtnAtaqueMais
@onready var btn_ataque_menos  = $Painel/MarginContainer/VBoxContainer/Corpo/ColunaEsquerda/Atributos/LinhaAtaque/BtnAtaqueMenos
@onready var btn_vida_mais     = $Painel/MarginContainer/VBoxContainer/Corpo/ColunaEsquerda/Atributos/LinhaVida/BtnVidaMais
@onready var btn_vida_menos    = $Painel/MarginContainer/VBoxContainer/Corpo/ColunaEsquerda/Atributos/LinhaVida/BtnVidaMenos
@onready var btn_vel_mais      = $Painel/MarginContainer/VBoxContainer/Corpo/ColunaEsquerda/Atributos/LinhaVelocidade/BtnVelMais
@onready var btn_vel_menos     = $Painel/MarginContainer/VBoxContainer/Corpo/ColunaEsquerda/Atributos/LinhaVelocidade/BtnVelMenos

@onready var btn_guerreiro     = $Painel/MarginContainer/VBoxContainer/Corpo/ColunaDireita/TipoUnidade/BtnGuerreiro
@onready var btn_arqueiro      = $Painel/MarginContainer/VBoxContainer/Corpo/ColunaDireita/TipoUnidade/BtnArqueiro
@onready var btn_canhao        = $Painel/MarginContainer/VBoxContainer/Corpo/ColunaDireita/TipoUnidade/BtnCanhao

@onready var btn_confirmar     = $Painel/MarginContainer/VBoxContainer/Rodape/BtnConfirmar

@onready var img_borda  = $Painel/MarginContainer/VBoxContainer/Corpo/ColunaEsquerda/PreviewGravura/ImgBorda
@onready var img_icone  = $Painel/MarginContainer/VBoxContainer/Corpo/ColunaEsquerda/PreviewGravura/ImgIcone

var carimbo: Carimbo


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

	$Painel/MarginContainer.add_theme_constant_override("margin_left",   24)
	$Painel/MarginContainer.add_theme_constant_override("margin_right",  24)
	$Painel/MarginContainer.add_theme_constant_override("margin_top",    24)
	$Painel/MarginContainer.add_theme_constant_override("margin_bottom", 24)

	btn_ataque_mais.pressed.connect(func():  _alterar("ataque",      1))
	btn_ataque_menos.pressed.connect(func(): _alterar("ataque",     -1))
	btn_vida_mais.pressed.connect(func():    _alterar("vida",        1))
	btn_vida_menos.pressed.connect(func():   _alterar("vida",       -1))
	btn_vel_mais.pressed.connect(func():     _alterar("velocidade",  1))
	btn_vel_menos.pressed.connect(func():    _alterar("velocidade", -1))

	btn_guerreiro.pressed.connect(func(): _selecionar_unidade(Carimbo.TipoUnidade.GUERREIRO))
	btn_arqueiro.pressed.connect(func():  _selecionar_unidade(Carimbo.TipoUnidade.ARQUEIRO))
	btn_canhao.pressed.connect(func():    _selecionar_unidade(Carimbo.TipoUnidade.CANHAO))

	btn_confirmar.pressed.connect(_on_confirmar)
	
	var cor_fonte = Color(0, 0, 0)

	label_raridade.add_theme_color_override("font_color", cor_fonte)
	label_pre_alocado.add_theme_color_override("font_color", Color(0, 0, 0))
	label_pontos.add_theme_color_override("font_color", cor_fonte)
	label_ataque.add_theme_color_override("font_color", Color(0.87, 0.31, 0.31))
	label_vida.add_theme_color_override("font_color", Color(0.31, 0.75, 0.31))
	label_velocidade.add_theme_color_override("font_color", Color(0.31, 0.56, 0.87))
	
	var cor_botao = Color(0, 0, 0)

	btn_guerreiro.add_theme_color_override("font_color", cor_botao)
	btn_arqueiro.add_theme_color_override("font_color", cor_botao)
	btn_canhao.add_theme_color_override("font_color", cor_botao)
	btn_confirmar.add_theme_color_override("font_color", cor_botao)
	btn_ataque_mais.add_theme_color_override("font_color", cor_botao)
	btn_ataque_menos.add_theme_color_override("font_color", cor_botao)
	btn_vida_mais.add_theme_color_override("font_color", cor_botao)
	btn_vida_menos.add_theme_color_override("font_color", cor_botao)
	btn_vel_mais.add_theme_color_override("font_color", cor_botao)
	btn_vel_menos.add_theme_color_override("font_color", cor_botao)
	
	ajustar_tamanho_e_centralizar(0.75)


func carregar_carimbo(c: Carimbo):
	carimbo = c
	_atualizar_display()


func _atualizar_display():
	if carimbo == null:
		return

	# Raridade
	label_raridade.text = Carimbo.NOMES_RARIDADE[carimbo.raridade].to_upper()
	label_raridade.add_theme_color_override("font_color", Carimbo.CORES_RARIDADE[carimbo.raridade])

	# Pré-alocados
	var pre = carimbo.pontos_gastos()
	label_pre_alocado.text    = "+%d pré-alocados" % pre if pre > 0 else ""
	label_pre_alocado.visible = pre > 0

	# Pontos
	label_pontos.text = "Pontos livres: %d / %d" % [carimbo.pontos_restantes(), carimbo.pontos_totais]

	# Barras
	barra_ataque.value    = carimbo.ataque
	barra_vida.value      = carimbo.vida
	barra_velocidade.value = carimbo.velocidade

	label_ataque.text     = str(carimbo.ataque)
	label_vida.text       = str(carimbo.vida)
	label_velocidade.text = str(carimbo.velocidade)

	# Botões habilitados/desabilitados
	btn_ataque_mais.disabled  = not carimbo.pode_adicionar("ataque")
	btn_ataque_menos.disabled = not carimbo.pode_remover("ataque")
	btn_vida_mais.disabled    = not carimbo.pode_adicionar("vida")
	btn_vida_menos.disabled   = not carimbo.pode_remover("vida")
	btn_vel_mais.disabled     = not carimbo.pode_adicionar("velocidade")
	btn_vel_menos.disabled    = not carimbo.pode_remover("velocidade")



func _alterar(atributo: String, delta: int):
	if carimbo == null:
		return
	if delta > 0 and carimbo.pode_adicionar(atributo):
		carimbo.set(atributo, carimbo.get(atributo) + 1)
	elif delta < 0 and carimbo.pode_remover(atributo):
		carimbo.set(atributo, carimbo.get(atributo) - 1)
	_atualizar_display()


func _selecionar_unidade(tipo: Carimbo.TipoUnidade):
	carimbo.tipo_unidade = tipo
	_destacar_unidade(tipo)
	_atualizar_preview()


func _destacar_unidade(tipo: Carimbo.TipoUnidade):
	for btn in [btn_guerreiro, btn_arqueiro, btn_canhao]:
		btn.modulate = Color(1, 1, 1, 1)
	match tipo:
		Carimbo.TipoUnidade.GUERREIRO: btn_guerreiro.modulate = Color(1.5, 1.2, 0.2, 1)
		Carimbo.TipoUnidade.ARQUEIRO:  btn_arqueiro.modulate  = Color(1.5, 1.2, 0.2, 1)
		Carimbo.TipoUnidade.CANHAO:    btn_canhao.modulate    = Color(1.5, 1.2, 0.2, 1)


func _on_confirmar():
	get_tree().paused = false
	carimbo_confirmado.emit(carimbo)
	queue_free()


func _atualizar_preview():
	# Atualiza borda conforme raridade
	match carimbo.raridade:
		Carimbo.Raridade.COMUM:   img_borda.texture = borda_comum
		Carimbo.Raridade.INCOMUM: img_borda.texture = borda_incomum
		Carimbo.Raridade.RARO:    img_borda.texture = borda_raro

	# Atualiza ícone conforme tipo de unidade
	match carimbo.tipo_unidade:
		Carimbo.TipoUnidade.GUERREIRO: img_icone.texture = icone_guerreiro
		Carimbo.TipoUnidade.ARQUEIRO:  img_icone.texture = icone_arqueiro
		Carimbo.TipoUnidade.CANHAO:    img_icone.texture = icone_canhao

## Ajusta o tamanho do menu e o centraliza na tela
func ajustar_tamanho_e_centralizar(fator_escala: float = 0.8):
	# 1. Aplica a escala ao nó raiz (DisplayCarimbo)
	self.scale = Vector2(fator_escala, fator_escala)
	
	# 2. Define o Pivot Offset para o centro do próprio menu
	# Isso garante que a escala e a rotação ocorram a partir do meio
	self.pivot_offset = self.size / 2
	
	# 3. Centraliza o nó na tela (Viewport)
	# Pegamos o tamanho da tela e subtraímos metade do tamanho ocupado pelo menu
	var tamanho_tela = get_viewport_rect().size
	self.position = (tamanho_tela / 2) - (self.size / 2)
