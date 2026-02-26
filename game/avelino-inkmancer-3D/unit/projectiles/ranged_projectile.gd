extends Projectile
class_name RangedProjectile

@onready var mesh: MeshInstance3D = $MeshInstance3D

func _physics_process(delta):

	if has_collided:
		return

	super._physics_process(delta)
	
func on_hit_environment(body: Node) -> void:
	stick_to_surface()
	
func on_hit_unit(unit: BaseUnit) -> void:
	queue_free()
	
func stick_to_surface():

	freeze = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

	collision_layer = 0
	collision_mask = 0

	await get_tree().create_timer(max_lifetime).timeout

	queue_free()
