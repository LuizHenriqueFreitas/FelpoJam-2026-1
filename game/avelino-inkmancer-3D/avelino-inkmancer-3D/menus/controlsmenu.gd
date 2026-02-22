extends Control

const ACTIONS = {
	"walk_left":    "Mover Esquerda",
	"walk_right":   "Mover Direita",
	"walk_front":   "Mover Frente",
	"walk_back":    "Mover Trás",
	"atack":        "Atacar",
	"summon":       "Invocar",
	# adicione mais ações conforme seu jogo
}

@onready var grid = $VBoxContainer/GridControles
@onready var btn_voltar = $VBoxContainer/BtnVoltar

var modo_ingame := false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	btn_voltar.pressed.connect(_on_voltar)
	_preencher_controles()

func _preencher_controles():
	for action in ACTIONS.keys():
		# Coluna 1: nome da ação
		var label_acao = Label.new()
		label_acao.text = ACTIONS[action]
		grid.add_child(label_acao)

		# Coluna 2: tecla associada
		var label_tecla = Label.new()
		label_tecla.text = _get_key_name(action)
		grid.add_child(label_tecla)

func _get_key_name(action: String) -> String:
	var events = InputMap.action_get_events(action)
	if events.is_empty():
		return "Não definido"

	for event in events:
		if event is InputEventKey:
			return event.as_text().replace(" (Physical)", "")  # remove sufixo desnecessário
		if event is InputEventJoypadButton:
			return "Botão " + str(event.button_index)

	return "Não definido"

func _on_voltar():
	if modo_ingame:
		queue_free()
	else:
		get_tree().change_scene_to_file("res://menus/mainmenu.tscn")
