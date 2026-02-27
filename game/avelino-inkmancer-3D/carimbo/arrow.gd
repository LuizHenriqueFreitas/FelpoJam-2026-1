extends Marker3D

@export var distance_from_camera : float = 3.0

var camera : Camera3D

func _ready():
	camera = get_parent()

func _process(delta):

	if ArrowManager.player == null:
		return
	
	if ArrowManager.carimbos.is_empty():
		visible = false
		return

	var closest = get_closest_carimbo()

	if closest == null:
		visible = false
		return

	update_position()
	update_rotation(closest)
	update_visibility(closest)


func get_closest_carimbo() -> Node3D:

	var player_pos = ArrowManager.player.global_position
	var closest : Node3D = null
	var min_dist := INF

	for c in ArrowManager.carimbos:
		if not is_instance_valid(c):
			continue
		
		var dist = player_pos.distance_to(c.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = c

	return closest


func update_position():
	position = Vector3(0, 0, -distance_from_camera)


func update_rotation(target: Node3D):
	look_at(target.global_position, Vector3.UP)


func update_visibility(target: Node3D):

	var player_pos = ArrowManager.player.global_position
	var dist = player_pos.distance_to(target.global_position)

	visible = dist > distance_from_camera
