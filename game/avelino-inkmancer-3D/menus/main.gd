extends Node3D

# teste, seria o game.tscn no teu note

@onready var hud = $hud


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


const DISPLAY_SCENE = preload("res://menus/displaycarimbo.tscn")

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_T:
		_testar_display()


func _testar_display():
	var c = Carimbo.new()
	var raridade_teste = Carimbo.Raridade.values()[randi() % 3]
	c.inicializar(raridade_teste)

	var display = DISPLAY_SCENE.instantiate()
	get_tree().root.add_child(display)
	display.carregar_carimbo(c)
	display.carimbo_confirmado.connect(_on_carimbo_recebido)


func _on_carimbo_recebido(c: Carimbo):
	print("Carimbo confirmado!")
	print("Raridade: ",   Carimbo.NOMES_RARIDADE[c.raridade])
	print("Tipo: ",       Carimbo.NOMES_UNIDADE[c.tipo_unidade])
	print("Ataque: ",     c.ataque)
	print("Vida: ",       c.vida)
	print("Velocidade: ", c.velocidade)
