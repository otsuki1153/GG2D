extends Area2D

@onready var particles := $GPUParticles2D
@onready var audio = $AudioStreamPlayer
@export var ball: RigidBody2D
@export var lineDrawer: Node2D


func _on_body_entered(body: Node2D) -> void:
	if body == ball:
		particles.restart()
		particles.emitting = true
		ball.linear_velocity = Vector2.ZERO
		var tween = get_tree().create_tween()
		tween.tween_property(body, "scale", Vector2(0, 0), 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		audio.play()
		await  tween.finished
		get_tree().reload_current_scene()
