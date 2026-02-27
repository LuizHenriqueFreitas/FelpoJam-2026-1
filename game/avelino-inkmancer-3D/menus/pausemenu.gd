extends Control

const MAIN_MENU_SCENE = "res://menus/mainmenu.tscn"

@onready var btn_voltar    = $Pergaminho/voltar
@onready var btn_controles = $Pergaminho/controle
@onready var btn_audio     = $Pergaminho/audio
@onready var btn_sair      = $Pergaminho/sair
@onready var pergaminho = $Pergaminho

var confirm_dialog: ConfirmationDialog
var modo_ingame := false


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	btn_voltar.pressed.connect(_on_voltar)
	btn_controles.pressed.connect(_on_controles)
	btn_audio.pressed.connect(_on_audio)
	btn_sair.pressed.connect(_on_sair)

	_criar_confirmacao()
	_pausar()
	call_deferred("_centralizar_menu")

func _criar_confirmacao():
	confirm_dialog = ConfirmationDialog.new()
	confirm_dialog.title = "Sair para o Menu?"
	confirm_dialog.dialog_text = "Seu progresso será perdido.\nDeseja continuar?"
	confirm_dialog.ok_button_text = "Sim, sair"
	confirm_dialog.cancel_button_text = "Cancelar"
	confirm_dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	confirm_dialog.confirmed.connect(_confirmar_saida)
	add_child(confirm_dialog)


func _pausar():
	get_tree().paused = true


func _despausar():
	get_tree().paused = false


func _on_voltar():
	_despausar()
	queue_free()


func _on_audio():
	visible = false
	var audio_menu = preload("res://menus/audiomenu.tscn").instantiate()
	audio_menu.modo_ingame = true
	audio_menu.tree_exited.connect(func():
		visible = true
		get_tree().paused = true
	)
	get_tree().root.add_child(audio_menu)

func _on_controles():
	visible = false
	var controls_menu = preload("res://menus/controlsmenu.tscn").instantiate()
	controls_menu.modo_ingame = true
	controls_menu.tree_exited.connect(func():
		visible = true
		get_tree().paused = true
	)
	get_tree().root.add_child(controls_menu)


func _on_sair():
	confirm_dialog.popup_centered()


func _confirmar_saida():
	_despausar()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_on_voltar()

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
