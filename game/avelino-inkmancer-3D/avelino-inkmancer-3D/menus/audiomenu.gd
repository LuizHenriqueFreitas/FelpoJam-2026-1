extends Control

const STEP = 10.0  # quanto cada click altera o volume

@onready var btn_musica_menos = $VBoxContainer/HBoxContainer/BtnMusicaMenos
@onready var btn_musica_mais = $VBoxContainer/HBoxContainer/BtnMusicaMais
@onready var bar_musica = $VBoxContainer/HBoxContainer/BarMusica

@onready var btn_sfx_menos = $VBoxContainer/HBoxContainer2/BtnSFXMenos
@onready var btn_sfx_mais = $VBoxContainer/HBoxContainer2/BtnSFXMais
@onready var bar_sfx = $VBoxContainer/HBoxContainer2/BarSFX

@onready var btn_voltar = $VBoxContainer/BtnVoltar

var modo_ingame := false

# O índice de canais de áudio
var music_bus := AudioServer.get_bus_index("Music")
var sfx_bus := AudioServer.get_bus_index("SFX")

func _ready():
	# Carrega o valor de volume dos canais na barra
	process_mode = Node.PROCESS_MODE_ALWAYS
	bar_musica.value = _db_to_percent(AudioServer.get_bus_volume_db(music_bus))
	bar_sfx.value = _db_to_percent(AudioServer.get_bus_volume_db(sfx_bus))

	btn_musica_menos.pressed.connect(_on_musica_menos)
	btn_musica_mais.pressed.connect(_on_musica_mais)
	btn_sfx_menos.pressed.connect(_on_sfx_menos)
	btn_sfx_mais.pressed.connect(_on_sfx_mais)
	btn_voltar.pressed.connect(_on_voltar)

func _on_musica_menos():
	bar_musica.value = clamp(bar_musica.value - STEP, 0, 100)
	_set_bus_volume(music_bus, bar_musica.value)

func _on_musica_mais():
	bar_musica.value = clamp(bar_musica.value + STEP, 0, 100)
	_set_bus_volume(music_bus, bar_musica.value)

func _on_sfx_menos():
	bar_sfx.value = clamp(bar_sfx.value - STEP, 0, 100)
	_set_bus_volume(sfx_bus, bar_sfx.value)

func _on_sfx_mais():
	bar_sfx.value = clamp(bar_sfx.value + STEP, 0, 100)
	_set_bus_volume(sfx_bus, bar_sfx.value)

func _on_voltar():
	if modo_ingame:
		queue_free()
	else:
		get_tree().change_scene_to_file("res://menus/mainmenu.tscn")

# Converte percentual (0-100) para decibéis e aplica no bus
func _set_bus_volume(bus_index: int, percent: float):
	if percent == 0:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		var db = linear_to_db(percent / 100.0)
		AudioServer.set_bus_volume_db(bus_index, db)

# Converte decibéis de volta para percentual para exibir na barra
func _db_to_percent(db: float) -> float:
	return db_to_linear(db) * 100.0
