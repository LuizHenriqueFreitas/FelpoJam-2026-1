extends Node

func _ready():
	var screen = DisplayServer.window_get_current_screen()
	var screen_size = DisplayServer.screen_get_size(screen)

	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(screen_size)
