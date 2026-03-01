extends Control

@export var radius: float = 45
@export var color: Color = Color(1.0, 1.0, 0.0, 0.176) # amarelo com alpha baixo

func _draw():
	draw_circle(Vector2.ZERO, radius, color)

func _ready():
	queue_redraw()
