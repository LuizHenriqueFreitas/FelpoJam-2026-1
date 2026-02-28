extends Control

@export var radius: float = 91
@export var color: Color = Color(1.0, 1.0, 0.0, 0.176) # amarelo com alpha baixo

var _scale: Vector2 = Vector2(0.765, 0.665)

func _draw():
	var center = size / 2
	
	draw_set_transform(center, 0.0, _scale)
	draw_circle(Vector2.ZERO, radius, color)
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _ready():
	queue_redraw()
