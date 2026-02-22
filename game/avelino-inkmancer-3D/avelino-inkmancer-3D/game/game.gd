extends Node3D

@onready var hud = $HUD

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

const PAUSE_MENU = preload("res://menus/pausemenu.tscn")
var pause_menu_aberto := false


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and not pause_menu_aberto:
		_abrir_pause()


func _abrir_pause():
	pause_menu_aberto = true
	var menu = PAUSE_MENU.instantiate()
	# Quando o menu for removido, marca como fechado
	menu.tree_exited.connect(func(): pause_menu_aberto = false)
	add_child(menu)
