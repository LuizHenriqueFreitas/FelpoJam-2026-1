extends Control

@onready var btn_voltar    = $Panel/VBoxContainer/BtnVoltar
@onready var btn_audio     = $Panel/VBoxContainer/BtnAudio
@onready var btn_controles = $Panel/VBoxContainer/BtnControles
@onready var btn_sair      = $Panel/VBoxContainer/BtnSair

# Popup de confirmação
var confirm_dialog: ConfirmationDialog


func _ready():
	btn_voltar.pressed.connect(_on_voltar)
	btn_audio.pressed.connect(_on_audio)
	btn_controles.pressed.connect(_on_controles)
	btn_sair.pressed.connect(_on_sair)
	
	_criar_confirmacao()
	_pausar()


func _criar_confirmacao():
	confirm_dialog = ConfirmationDialog.new()
	confirm_dialog.title = "Sair para o Menu?"
	confirm_dialog.dialog_text = "Seu progresso não salvo será perdido.\nDeseja continuar?"
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
	queue_free()  # remove a cena do pause e volta pro jogo

func _on_audio():
	visible = false
	var audio_menu = preload("res://menus/audiomenu.tscn").instantiate()
	audio_menu.modo_ingame = true
	audio_menu.tree_exited.connect(func(): visible = true)
	get_tree().root.add_child(audio_menu)

func _on_controles():
	visible = false
	var controls_menu = preload("res://menus/controlsmenu.tscn").instantiate()
	controls_menu.modo_ingame = true
	controls_menu.tree_exited.connect(func(): visible = true)
	get_tree().root.add_child(controls_menu)

func _on_sair():
	confirm_dialog.popup_centered()

func _confirmar_saida():
	_despausar()
	get_tree().change_scene_to_file("res://menus/mainmenu.tscn")

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"): # Fecha o menu de pause com o esc também
		_on_voltar()
