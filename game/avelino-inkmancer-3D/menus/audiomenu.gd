extends Control

var modo_ingame := false

@onready var slider_musica  = $Pergaminho/SliderMusica
@onready var slider_efeitos = $Pergaminho/SliderEfeitos
@onready var btn_voltar     = $Pergaminho/BtnVoltar
@onready var label_musica  = $Pergaminho/LabelMusica
@onready var label_efeitos = $Pergaminho/LabelEfeitos

@onready var pergaminho = $Pergaminho

var music_bus: int
var sfx_bus: int


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	music_bus = AudioServer.get_bus_index("Music")
	sfx_bus   = AudioServer.get_bus_index("SFX")

	slider_musica.value  = _db_para_percent(AudioServer.get_bus_volume_db(music_bus))
	slider_efeitos.value = _db_para_percent(AudioServer.get_bus_volume_db(sfx_bus))

	slider_musica.value_changed.connect(_on_musica_alterada)
	slider_efeitos.value_changed.connect(_on_efeitos_alterados)

	btn_voltar.pressed.connect(_on_voltar)
	
	label_musica.text  = "%d" % int(slider_musica.value)
	label_efeitos.text = "%d" % int(slider_efeitos.value)
	
	if modo_ingame:
		call_deferred("_centralizar_menu")


func _on_musica_alterada(valor: float):
	_set_volume(music_bus, valor)
	label_musica.text = "%d" % int(valor)

func _on_efeitos_alterados(valor: float):
	_set_volume(sfx_bus, valor)
	label_efeitos.text = "%d" % int(valor)


func _set_volume(bus: int, percent: float):
	if bus == -1:
		return
	if percent == 0:
		AudioServer.set_bus_mute(bus, true)
	else:
		AudioServer.set_bus_mute(bus, false)
		AudioServer.set_bus_volume_db(bus, linear_to_db(percent / 100.0))


func _db_para_percent(db: float) -> float:
	return db_to_linear(db) * 100.0


func _on_voltar():
	queue_free()

func _input(event):
	if event.is_action_pressed("ui_cancel") and modo_ingame:
		get_viewport().set_input_as_handled()
		queue_free() 

func _centralizar_menu():
	await get_tree().process_frame
	pergaminho.scale = Vector2(0.5, 0.5)
	pergaminho.set_anchors_preset(Control.PRESET_CENTER)
	
	var metade = (pergaminho.size * pergaminho.scale) / 2
	pergaminho.offset_left   = -metade.x
	pergaminho.offset_top    = -metade.y
	pergaminho.offset_right  =  metade.x
	pergaminho.offset_bottom =  metade.y
	pergaminho.pivot_offset  = pergaminho.size / 2
