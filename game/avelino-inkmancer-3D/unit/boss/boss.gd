extends CharacterBody3D

var isAttacking : bool = false

func _physics_process(delta: float) -> void:
	
	if isAttacking:
		get_node("anjo/AnimationPlayer").play("attack")
	else:
		get_node("anjo/AnimationPlayer").play("idel")
