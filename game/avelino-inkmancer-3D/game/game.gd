extends Node3D

@onready var hud = $HUD

const PAUSE_MENU = preload("res://menus/pausemenu.tscn")
var pause_menu_aberto := false


func _unhandled_input(event):
	if event.is_action_pressed("pause") and not pause_menu_aberto:
		_abrir_pause()


func _abrir_pause():
	pause_menu_aberto = true
	var menu = PAUSE_MENU.instantiate()
	# Quando o menu for removido, marca como fechado
	menu.tree_exited.connect(func(): pause_menu_aberto = false)
	add_child(menu)
	

	
