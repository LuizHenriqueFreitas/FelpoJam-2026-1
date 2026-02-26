extends Projectile
class_name SiegeProjectile

func on_hit_unit(unit: BaseUnit) -> void:
	queue_free()


func on_hit_environment(body: Node) -> void:
	queue_free()
