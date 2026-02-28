extends Control

const GAME_SCENE = "res://game/game.tscn"
const MENU_SCENE = "res://menus/mainmenu.tscn"

@onready var label_titulo = $Conteudo/LabelTitulo
@onready var btn_primario = $Conteudo/BtnPrimario
@onready var btn_sair     = $Conteudo/BtnSair

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

	label_titulo.text = "Você Morreu!"
	label_titulo.add_theme_color_override("font_color", Color(0.8, 0.1, 0.1))

	btn_primario.pressed.connect(_on_tentar)
	btn_sair.pressed.connect(_on_sair)

	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)


func _on_tentar():
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_sair():
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file(MENU_SCENE)
