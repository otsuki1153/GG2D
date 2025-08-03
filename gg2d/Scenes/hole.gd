extends Area2D

@export var ball: RigidBody2D

func _on_body_entered(body: Node2D) -> void:
	if ball:
		get_tree().reload_current_scene()
