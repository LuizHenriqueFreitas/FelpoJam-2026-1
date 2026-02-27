extends Node

@export var interface_scene_melee: PackedScene
@export var interface_scene_ranged: PackedScene
@export var interface_scene_siege: PackedScene
@export var interface_scene_common: PackedScene
@export var interface_scene_uncommon: PackedScene
@export var interface_scene_rare: PackedScene
@export var canvas_layer_path: NodePath

var canvas_layer: CanvasLayer
var screen_position: Vector2
var instance_unit_type
var instance_unit_rarity

func _ready():
	canvas_layer = get_node(canvas_layer_path)

func spawn_interface(index: float, unit_type: Carimbo.TipoUnidade, rarity: Carimbo.Raridade):
	if !interface_scene_melee || !interface_scene_ranged || !interface_scene_siege:
		push_error("interface_scene não atribuída!")
		return
		
	match unit_type:
		Carimbo.TipoUnidade.GUERREIRO:
			instance_unit_type = interface_scene_melee.instantiate()
		Carimbo.TipoUnidade.ARQUEIRO:
			instance_unit_type = interface_scene_ranged.instantiate()
		Carimbo.TipoUnidade.CANHAO:
			instance_unit_type = interface_scene_siege.instantiate()
			
	match rarity:
		Carimbo.Raridade.COMUM:
			instance_unit_rarity = interface_scene_common.instantiate()
		Carimbo.Raridade.INCOMUM:
			instance_unit_rarity = interface_scene_uncommon.instantiate()
		Carimbo.Raridade.RARO:
			instance_unit_rarity = interface_scene_rare.instantiate()
	
	canvas_layer.add_child(instance_unit_type)
	canvas_layer.add_child(instance_unit_rarity)

	await get_tree().process_frame

	instance_unit_type.position = screen_position - instance_unit_type.size / 2
	instance_unit_rarity.position = screen_position - instance_unit_rarity.size / 2
	
	if index < 0 || index > 3:
		print("indice está sendo enviado errado: ", index)
		return
	
	match index:
		0: screen_position = Vector2(120, 90)
		1: screen_position = Vector2(240, 90)
		2: screen_position = Vector2(360, 90)
		3: screen_position = Vector2(480, 90)
	
	if instance_unit_type is Control:
		instance_unit_type.global_position = screen_position
	else:
		push_warning("A cena instanciada não é um Control!")
		
	if instance_unit_rarity is Control:
		instance_unit_rarity.global_position = screen_position
	else:
		push_warning("A cena instanciada não é um Control!")
