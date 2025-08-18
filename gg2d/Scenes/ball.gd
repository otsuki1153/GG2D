extends RigidBody2D

@onready var camera = $Camera2D
@export var line: Node2D
@export var maxVelocity: float = 1500.0


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if linear_velocity.length() > maxVelocity:
		linear_velocity = linear_velocity.normalized() * maxVelocity
		
	if state.get_contact_count() > 0:
		for i in range(state.get_contact_count()):
			var normal: Vector2 = state.get_contact_local_normal(i)
			var velo: Vector2 = linear_velocity
			var reflected: Vector2 = velo - 2.0 * velo.dot(normal) * normal
			linear_velocity = reflected
			
			
	if linear_velocity.length() > 1.0:
		var friction = 20
		linear_velocity = linear_velocity.move_toward(Vector2.ZERO, friction * state.get_step())
	else:
		linear_velocity = Vector2.ZERO
	
		
	
