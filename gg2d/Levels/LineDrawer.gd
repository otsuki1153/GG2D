extends Node2D

var dragging: bool = false
var dragStart := Vector2.ZERO
@export var LimitForce: float = 300
@export var maxShots: int  = 5
var shotNumb: int = 0
@onready var shotLabel := get_node("/root/MainGame/UI/shotPanel/shotLabel")

@onready var line := Line2D.new()
@export var ball: RigidBody2D
@onready var cam := ball.get_node("Camera2D")

@onready var  audioToma = $AudioStreamPlayer




func _ready() -> void:
	var gradient := Gradient.new()
	gradient.add_point(0.0, Color(0.0, 0.0,0.0,1.0))
	gradient.add_point(1.0, Color(0.0, 0.0,0.0,0.0))
	line.width = 16.0
	line.texture = preload("res://Assets/Point Line.png")
	line.set_texture_mode(Line2D.LineTextureMode.LINE_TEXTURE_TILE)
	line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	line.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	#line.default_color = Color.CYAN
	line.gradient = gradient
	line.set_begin_cap_mode(Line2D.LineCapMode.LINE_CAP_ROUND)
	line.set_end_cap_mode(Line2D.LINE_CAP_ROUND)
	line.set_joint_mode(Line2D.LINE_JOINT_ROUND)
	line.round_precision = 4
	line.antialiased = true
	add_child(line)
	updateShotStatus()

func getMouseCamPosition() -> Vector2:
	var cam = get_viewport().get_camera_2d()
	if cam:
		return cam.get_global_mouse_position()
	else:
		return get_viewport().get_mouse_position()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			if ball.linear_velocity.length() < 1.0:
				var mouseGlobalPosition = getMouseCamPosition()
				if ball.global_position.distance_to(mouseGlobalPosition) < 32:
					dragging = true
					dragStart = mouseGlobalPosition
		else:
			if shotNumb >= maxShots:
				get_tree().reload_current_scene()
				return
			if dragging:
				dragging = false
				var mouseGlobalPosition = getMouseCamPosition()
				var force = dragStart - mouseGlobalPosition
				if force.length() > LimitForce:
					force = force.normalized() * LimitForce
					mouseGlobalPosition = dragStart - force
				#audioToma.pitch_scale = lerp(1.0, 0.5, force.length() / LimitForce)
				audioToma.volume_db = lerp(-30.0, 20.0, force.length() / LimitForce)
				var tween = get_tree().create_tween()
				tween.tween_property(cam, "zoom", Vector2(1, 1), 0.3)
				ball.apply_force(force * LimitForce)
				shotNumb += 1
				audioToma.play()
				updateShotStatus()
	elif event is InputEventMouseMotion and dragging:
		var tween = get_tree().create_tween()
		tween.tween_property(cam, "zoom", Vector2(2, 2), 0.3)
		if shotNumb >= maxShots:
			return
		var mouseGlobalPosition = getMouseCamPosition()
		var force = dragStart - mouseGlobalPosition

		if force.length() > 150:
			force = force.normalized() * 140
			mouseGlobalPosition = dragStart - force

		line.clear_points()
		line.add_point(Vector2.ZERO)
		line.add_point(to_local(mouseGlobalPosition))

func _physics_process(delta: float) -> void:
	global_position = ball.global_position
	if !dragging:
		line.clear_points()
		
func updateShotStatus():
	shotLabel.text = "TACADAS: %d/%d" %[shotNumb, maxShots]
