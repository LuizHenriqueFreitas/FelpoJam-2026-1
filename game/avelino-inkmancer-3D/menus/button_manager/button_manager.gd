extends Node
class_name ButtonManager

@export var interface_scene_melee: PackedScene
@export var interface_scene_ranged: PackedScene
@export var interface_scene_siege: PackedScene
@export var interface_scene_common: PackedScene
@export var interface_scene_uncommon: PackedScene
@export var interface_scene_rare: PackedScene
@export var canvas_layer_path: NodePath

var canvas_layer: CanvasLayer
var instance_unit_type
var instance_unit_rarity
var selected_slot
var scale1: Vector2 = Vector2(0.765, 0.665)
var scale2: Vector2 = Vector2(0.77, 0.67)
var hud_selecter1
var hud_selecter2
var hud_selecter3
var hud_selecter4


func _ready():
	canvas_layer = get_node(canvas_layer_path)
	hud_selecter1 = get_node("../HUD/HUDRoot/SlotSelecter1")
	hud_selecter2 = get_node("../HUD/HUDRoot/SlotSelecter2")
	hud_selecter3 = get_node("../HUD/HUDRoot/SlotSelecter3")
	hud_selecter4 = get_node("../HUD/HUDRoot/SlotSelecter4")
	hud_selecter1.hide()
	hud_selecter2.hide()
	hud_selecter3.hide()
	hud_selecter4.hide()

func spawn_interface(index: int, unit_type: Carimbo.TipoUnidade, rarity: Carimbo.Raridade):

	if !interface_scene_melee or !interface_scene_ranged or !interface_scene_siege:
		push_error("interface_scene não atribuída!")
		return

	# Instancia tipo de unidade
	match unit_type:
		Carimbo.TipoUnidade.GUERREIRO:
			instance_unit_type = interface_scene_melee.instantiate()
		Carimbo.TipoUnidade.ARQUEIRO:
			instance_unit_type = interface_scene_ranged.instantiate()
		Carimbo.TipoUnidade.CANHAO:
			instance_unit_type = interface_scene_siege.instantiate()

	# Instancia raridade
	match rarity:
		Carimbo.Raridade.COMUM:
			instance_unit_rarity = interface_scene_common.instantiate()
		Carimbo.Raridade.INCOMUM:
			instance_unit_rarity = interface_scene_uncommon.instantiate()
		Carimbo.Raridade.RARO:
			instance_unit_rarity = interface_scene_rare.instantiate()

	# Valida índice
	if index < 0 or index > 3:
		push_error("Índice inválido")
		return

	# Ajuste o caminho se necessário
	var slot := get_node_or_null("../HUD/HUDRoot/Slot%d" % index) as Control

	if slot == null:
		push_error("Slot não encontrado. Verifique o caminho.")
		return

	# Adiciona ao Canvas (raridade atrás, tipo por cima)
	canvas_layer.add_child(instance_unit_rarity)
	canvas_layer.add_child(instance_unit_type)

	await get_tree().process_frame

	# 🔧 AJUSTE AQUI PARA TESTES DE DISTORÇÃO
	instance_unit_rarity.scale = scale1
	instance_unit_type.scale = scale2

	# Centro do slot
	var center = slot.position + slot.size / 2

	# Tamanho visual real (considerando escala)
	var rarity_size = instance_unit_rarity.size * instance_unit_rarity.scale
	var type_size = instance_unit_type.size * instance_unit_type.scale

	# Centraliza corretamente mesmo com distorção
	instance_unit_rarity.position = center - rarity_size / 2
	instance_unit_type.position = center - type_size / 2
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("slot_1"):
		hud_selecter1.show()
		hud_selecter2.hide()
		hud_selecter3.hide()
		hud_selecter4.hide()
	
	if event.is_action_pressed("slot_2"):
		hud_selecter1.hide()
		hud_selecter2.show()
		hud_selecter3.hide()
		hud_selecter4.hide()	
			
	if event.is_action_pressed("slot_3"):
		hud_selecter1.hide()
		hud_selecter2.hide()
		hud_selecter3.show()
		hud_selecter4.hide()
		
	if event.is_action_pressed("slot_4"):
		hud_selecter1.hide()
		hud_selecter2.hide()
		hud_selecter3.hide()
		hud_selecter4.show()
		
	
	
