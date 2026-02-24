extends Camera3D

@onready var player = $"../Player"

var offset: Vector3

# Ajuste pro personagem não ficar dando pixel jumping
@export var pixel_size: float = 0.01

func _ready() -> void:
	# Guarda a distância inicial entre câmera e player
	offset = global_position - player.global_position

func _physics_process(delta: float) -> void:
	var target_position = player.global_position + offset
	var smooth_pos = global_position.lerp(target_position, 1.0 - exp(-5.0 * delta))
	
	global_position = Vector3(
		snapped(smooth_pos.x, pixel_size),
		snapped(smooth_pos.y, pixel_size),
		snapped(smooth_pos.z, pixel_size)
	)
