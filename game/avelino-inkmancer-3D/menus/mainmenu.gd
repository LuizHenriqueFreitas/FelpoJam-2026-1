extends Control

const ESCALA_MIN: float = 1.0
const ESCALA_MAX: float = 1.08
const VELOCIDADE_PULSO: float = 3.0

var botoes: Array
var hover_ativo: Dictionary
var tempo: float = 0.0

@onready var sub_menu_container = $SubMenuContainer
@onready var animated_sprite = $AnimatedSprite2D

@onready var btn_jogar          = $BtnJogar
@onready var btn_controles      = $BtnControles
@onready var btn_audio          = $BtnAudio
@onready var btn_sair           = $BtnSair

const IMAGENS = {
	"BtnJogar":     "res://texturacarimbos/carimbo-jogar.png",
	"BtnControles": "res://texturacarimbos/carimbo-controles.png",
	"BtnAudio":     "res://texturacarimbos/carimbo-audio.png",
	"BtnSair":      "res://texturacarimbos/carimbo-sair.png",
}


func _ready():
	botoes = [btn_jogar, btn_controles, btn_audio, btn_sair]

	for btn in botoes:
		hover_ativo[btn] = false
		btn.pivot_offset = btn.size / 2
		btn.mouse_entered.connect(func(): hover_ativo[btn] = true)
		btn.mouse_exited.connect(func():
			hover_ativo[btn] = false
			btn.scale = Vector2.ONE
		)
	$AnimatedSprite2D.set_meta("block_input", false)
	$TextureRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$SubMenuContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	animated_sprite.play("default")


func _process(delta):
	tempo += delta
	for btn in botoes:
		if hover_ativo[btn]:
			var pulso = (sin(tempo * VELOCIDADE_PULSO) + 1.0) / 2.0
			var escala = lerp(ESCALA_MIN, ESCALA_MAX, pulso)
			btn.scale = Vector2(escala, escala)


func _mostrar_carimbo(btn: Control, nome: String):
	var carimbo = TextureRect.new()
	carimbo.texture = load(IMAGENS[nome])
	carimbo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	carimbo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	carimbo.custom_minimum_size = Vector2(150, 150)
	carimbo.size = Vector2(150, 150)
	carimbo.pivot_offset = carimbo.size / 2
	carimbo.rotation_degrees = randf_range(-45.0, 45.0)

	var pos_mouse = btn.get_local_mouse_position()
	carimbo.position = btn.global_position + pos_mouse - carimbo.size / 2
	get_tree().current_scene.add_child(carimbo)

	var tween = create_tween()
	tween.tween_property(carimbo, "scale", Vector2(1.2, 1.2), 0.05)
	tween.tween_property(carimbo, "scale", Vector2(1.0, 1.0), 0.05)
	tween.tween_interval(0.3)
	tween.tween_property(carimbo, "modulate:a", 0.0, 0.2)
	tween.tween_callback(carimbo.queue_free)


func _abrir_submenu(caminho: String):
	for btn in botoes:
		btn.visible = false

	var submenu = load(caminho).instantiate()
	submenu.modo_ingame = false
	sub_menu_container.add_child(submenu)

	submenu.tree_exited.connect(func():
		for btn in botoes:
			btn.visible = true
	)


func _on_btn_jogar_pressed() -> void:
	_mostrar_carimbo(btn_jogar, "BtnJogar")
	await get_tree().create_timer(0.4).timeout
	get_tree().change_scene_to_file("res://game/game.tscn")


func _on_btn_audio_pressed() -> void:
	_mostrar_carimbo(btn_audio, "BtnAudio")
	await get_tree().create_timer(0.2).timeout
	_abrir_submenu("res://menus/audiomenu.tscn")

func _on_btn_controles_pressed() -> void:
	_mostrar_carimbo(btn_controles, "BtnControles")
	await get_tree().create_timer(0.2).timeout
	_abrir_submenu("res://menus/controlsmenu.tscn")


func _on_btn_sair_pressed() -> void:
	_mostrar_carimbo(btn_sair, "BtnSair")
	await get_tree().create_timer(0.4).timeout
	get_tree().quit()
