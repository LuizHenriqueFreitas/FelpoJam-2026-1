extends Node
class_name ButtonManager

const COOLDOWN_FONT := preload("res://utilitarios/EagleLake-Regular.ttf")

@export var interface_scene_melee: PackedScene
@export var interface_scene_ranged: PackedScene
@export var interface_scene_siege: PackedScene
@export var interface_scene_common: PackedScene
@export var interface_scene_uncommon: PackedScene
@export var interface_scene_rare: PackedScene
@export var canvas_layer_path: NodePath
@export var cooldown_icon_alpha: float = 0.6

var canvas_layer: CanvasLayer
var instance_unit_type
var instance_unit_rarity
var selected_slot
var scale1: Vector2 = Vector2(0.765, 0.665)
var scale2: Vector2 = Vector2(0.77, 0.67)
var slot_selected: int
var hud_selecter1
var hud_selecter2
var hud_selecter3
var hud_selecter4
var slot_unit_type_icons: Array = [null, null, null, null]
var slot_unit_rarity_icons: Array = [null, null, null, null]
var slot_cooldown_labels: Array[Label] = []
var slot_cooldowns: Array[float] = [0.0, 0.0, 0.0, 0.0]


func _ready():
	canvas_layer = get_node(canvas_layer_path)
	hud_selecter1 = get_node("../HUD/HUDRoot/SlotSelecter1")
	hud_selecter2 = get_node("../HUD/HUDRoot/SlotSelecter2")
	hud_selecter3 = get_node("../HUD/HUDRoot/SlotSelecter3")
	hud_selecter4 = get_node("../HUD/HUDRoot/SlotSelecter4")
	hud_selecter1.show()
	hud_selecter2.hide()
	hud_selecter3.hide()
	hud_selecter4.hide()
	slot_selected = 1
	_setup_cooldown_labels()


func _process(delta: float) -> void:
	for slot_idx in range(slot_cooldowns.size()):
		if slot_cooldowns[slot_idx] <= 0.0:
			continue

		slot_cooldowns[slot_idx] = max(slot_cooldowns[slot_idx] - delta, 0.0)
		_update_slot_cooldown_visual(slot_idx)


func _setup_cooldown_labels() -> void:
	for i in range(4):
		var slot := get_node_or_null("../HUD/HUDRoot/Slot%d" % i) as Control
		if slot == null:
			slot_cooldown_labels.append(null)
			continue

		var label := Label.new()
		label.visible = false
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size = Vector2(120, 120)
		label.scale = Vector2(0.9, 0.9)
		label.modulate = Color(0.0, 0.0, 0.0, 1.0)
		label.text = ""

		if COOLDOWN_FONT != null:
			label.add_theme_font_override("font", COOLDOWN_FONT)
			label.add_theme_font_size_override("font_size", 54)

		canvas_layer.add_child(label)
		slot_cooldown_labels.append(label)
		_position_cooldown_label(i)


func _position_cooldown_label(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= slot_cooldown_labels.size():
		return

	var label := slot_cooldown_labels[slot_index]
	if label == null:
		return

	var slot := get_node_or_null("../HUD/HUDRoot/Slot%d" % slot_index) as Control
	if slot == null:
		return

	var center = slot.position + slot.size / 2
	label.position = center - label.size / 2


func is_slot_on_cooldown(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= slot_cooldowns.size():
		return false
	return slot_cooldowns[slot_index] > 0.0


func get_slot_cooldown_remaining(slot_index: int) -> float:
	if slot_index < 0 or slot_index >= slot_cooldowns.size():
		return 0.0
	return slot_cooldowns[slot_index]


func start_slot_cooldown(slot_index: int, duration: float) -> void:
	if slot_index < 0 or slot_index >= slot_cooldowns.size():
		return

	slot_cooldowns[slot_index] = max(duration, 0.0)
	_update_slot_cooldown_visual(slot_index)


func _update_slot_cooldown_visual(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= slot_cooldowns.size():
		return

	var remaining := slot_cooldowns[slot_index]
	var on_cooldown := remaining > 0.0

	var type_icon = slot_unit_type_icons[slot_index]
	if type_icon != null:
		type_icon.modulate = Color(1, 1, 1, cooldown_icon_alpha) if on_cooldown else Color(1, 1, 1, 1)

	var rarity_icon = slot_unit_rarity_icons[slot_index]
	if rarity_icon != null:
		rarity_icon.modulate = Color(1, 1, 1, cooldown_icon_alpha) if on_cooldown else Color(1, 1, 1, 1)

	if slot_index >= slot_cooldown_labels.size():
		return

	var label := slot_cooldown_labels[slot_index]
	if label == null:
		return

	_position_cooldown_label(slot_index)

	if on_cooldown:
		label.visible = true
		label.text = str(int(ceil(remaining)))
	else:
		label.visible = false
		label.text = ""

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
	if slot_unit_type_icons[index] != null:
		slot_unit_type_icons[index].queue_free()
	if slot_unit_rarity_icons[index] != null:
		slot_unit_rarity_icons[index].queue_free()

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

	slot_unit_type_icons[index] = instance_unit_type
	slot_unit_rarity_icons[index] = instance_unit_rarity
	_update_slot_cooldown_visual(index)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("slot_1"):
		slot_selected = 1
		hud_selecter1.show()
		hud_selecter2.hide()
		hud_selecter3.hide()
		hud_selecter4.hide()
	
	if event.is_action_pressed("slot_2"):
		slot_selected = 2
		hud_selecter1.hide()
		hud_selecter2.show()
		hud_selecter3.hide()
		hud_selecter4.hide()	
			
	if event.is_action_pressed("slot_3"):
		slot_selected = 3
		hud_selecter1.hide()
		hud_selecter2.hide()
		hud_selecter3.show()
		hud_selecter4.hide()
		
	if event.is_action_pressed("slot_4"):
		slot_selected = 4
		hud_selecter1.hide()
		hud_selecter2.hide()
		hud_selecter3.hide()
		hud_selecter4.show()
		
	
	
