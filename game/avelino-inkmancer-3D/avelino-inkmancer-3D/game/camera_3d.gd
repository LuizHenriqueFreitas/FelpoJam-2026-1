extends Camera3D

@onready var player = $"../Player"

var offset: Vector3

func _ready() -> void:
	# Guarda a distância inicial entre câmera e player
	offset = global_position - player.global_position

func _process(delta: float) -> void:
	var target_position = player.global_position + offset
	global_position = global_position.lerp(target_position, 5.0 * delta)
