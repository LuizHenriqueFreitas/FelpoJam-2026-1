extends Control

var modo_ingame := false

const ACTIONS = {
	"walk_left":  "Mover Esquerda",
	"walk_right": "Mover Direita",
	"walk_up":    "Mover Cima",
	"walk_down":  "Mover Trás",
	"attack":     "Atacar",
	"summon":     "Invocar",
	"ui_cancel":  "Configurações"
	# adiciona mais se precisar
}

@onready var grid       = $Pergaminho/GridControles
@onready var btn_voltar = $Pergaminho/BtnVoltar


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	btn_voltar.pressed.connect(_on_voltar)
	_preencher_controles()


func _preencher_controles():
	for action in ACTIONS.keys():
		var label_acao = Label.new()
		label_acao.text = ACTIONS[action]
		_estilizar_label(label_acao)
		grid.add_child(label_acao)

		var label_tecla = Label.new()
		label_tecla.text = _get_key_name(action)
		_estilizar_label(label_tecla)
		grid.add_child(label_tecla)


func _estilizar_label(label: Label):
	# Cor do texto
	label.add_theme_color_override("font_color", Color(0, 0, 0))
	
	# Tamanho da fonte
	label.add_theme_font_size_override("font_size", 21)
	
	var fonte = preload("res://utilitarios/EagleLake-Regular.ttf")
	label.add_theme_font_override("font", fonte)


func _get_key_name(action: String) -> String:
	var events = InputMap.action_get_events(action)
	if events.is_empty():
		return "Não definido"
	
	for event in events:
		if event is InputEventKey:
			return event.as_text().replace(" (Physical)", "")
		if event is InputEventMouseButton:
			match event.button_index:
				MOUSE_BUTTON_LEFT:   return "Click Esquerdo"
				MOUSE_BUTTON_RIGHT:  return "Click Direito"
		if event is InputEventJoypadButton:
			return "Botão " + str(event.button_index)
	
	return "Não definido"


func _on_voltar():
	if modo_ingame:
		queue_free()
	else:
		get_tree().change_scene_to_file("res://menus/mainmenu.tscn")

func _input(event):
	if event.is_action_pressed("ui_cancel") and modo_ingame:
		get_viewport().set_input_as_handled()
		queue_free()
