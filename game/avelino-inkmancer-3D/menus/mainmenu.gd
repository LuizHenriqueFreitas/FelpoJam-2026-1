extends Control

# Velocidade e escala da animação do menu
const ESCALA_HOVER: float = 1.08
const VELOCIDADE: float = 8.0

var botoes: Array
var escalas_alvo: Dictionary

const IMAGENS = {
	"BtnJogar":    "res://texturacarimbos/carimbo-jogar.png",
	"BtnControles":"res://texturacarimbos/carimbo-controles.png",
	"BtnAudio":    "res://texturacarimbos/carimbo-audio.png",
	"BtnSair":     "res://texturacarimbos/carimbo-sair.png",
}

var carimbos_ativos: Array = []


func _ready():
	botoes = [$BtnJogar, $BtnControles, $BtnAudio, $BtnSair]
	
	for btn in botoes:
		escalas_alvo[btn] = 1.0
		btn.pivot_offset = btn.size / 2  # pivô no centro do botão
		btn.mouse_entered.connect(func(): escalas_alvo[btn] = ESCALA_HOVER)
		btn.mouse_exited.connect(func(): escalas_alvo[btn] = 1.0)


func _process(delta):
	for btn in botoes:
		var alvo = Vector2(escalas_alvo[btn], escalas_alvo[btn])
		btn.scale = btn.scale.lerp(alvo, VELOCIDADE * delta)


func _mostrar_carimbo(btn: Control, nome: String):
	var carimbo = TextureRect.new()
	carimbo.texture = load(IMAGENS[nome])
	carimbo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE  # ← adicione isso
	carimbo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED  # ← e isso
	carimbo.custom_minimum_size = Vector2(150, 150)  # ← use custom_minimum_size
	carimbo.size = Vector2(32, 32)
	carimbo.pivot_offset = carimbo.size / 2

	var pos_mouse = btn.get_local_mouse_position()
	carimbo.position = btn.global_position + pos_mouse - carimbo.size / 2

	get_tree().current_scene.add_child(carimbo)

	var tween = create_tween()
	tween.tween_property(carimbo, "scale", Vector2(1.2, 1.2), 0.05)
	tween.tween_property(carimbo, "scale", Vector2(1.0, 1.0), 0.05)
	tween.tween_interval(0.3)
	tween.tween_property(carimbo, "modulate:a", 0.0, 0.2)
	tween.tween_callback(carimbo.queue_free)

func _on_btn_jogar_pressed() -> void:
	_mostrar_carimbo($BtnJogar, "BtnJogar")
	await get_tree().create_timer(0.4).timeout  # faz o jogo esperar o carimbo aparecer antes de iniciar/trocar de cena
	get_tree().change_scene_to_file("res://game/game.tscn")

func _on_btn_controles_pressed() -> void:
	_mostrar_carimbo($BtnControles, "BtnControles")
	await get_tree().create_timer(0.4).timeout
	get_tree().change_scene_to_file("res://menus/controlsmenu.tscn")

func _on_btn_audio_pressed() -> void:
	_mostrar_carimbo($BtnAudio, "BtnAudio")
	await get_tree().create_timer(0.4).timeout
	get_tree().change_scene_to_file("res://menus/audiomenu.tscn")

func _on_btn_sair_pressed() -> void:
	_mostrar_carimbo($BtnSair, "BtnSair")
	await get_tree().create_timer(0.4).timeout
	get_tree().quit()
