extends Control

@onready var btn_jogar = $VBoxContainer/BtnJogar
@onready var btn_controles = $VBoxContainer/BtnControles
@onready var btn_audio = $VBoxContainer/BtnAudio
@onready var btn_sair = $VBoxContainer/BtnSair


func _ready():
	btn_jogar.pressed.connect(_on_jogar_pressed)
	btn_controles.pressed.connect(_on_controles_pressed)
	btn_audio.pressed.connect(_on_audio_pressed)
	btn_sair.pressed.connect(_on_sair_pressed)

func _on_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://game/game.tscn")

func _on_controles_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/controlsmenu.tscn")

func _on_audio_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/audiomenu.tscn")

func _on_sair_pressed() -> void:
	get_tree().quit() 
