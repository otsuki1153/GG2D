extends RigidBody2D

@onready var camera = $Camera2D

func _physics_process(delta: float) -> void:
	
	if linear_velocity.length() > 1.0:
		linear_velocity *= 0.98
	else:
		linear_velocity = Vector2.ZERO
	
