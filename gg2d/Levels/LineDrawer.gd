extends Node2D

var dragging: bool = false
var dragStart := Vector2.ZERO


@onready var line := Line2D.new()
@export var ball: RigidBody2D

func _ready() -> void:
	line.width = 8.0
	#line.texture = preload("res://Assets/Point Line.png")
	#line.set_texture_mode(Line2D.LineTextureMode.LINE_TEXTURE_NONE)
	add_child(line)

func getMouseCamPosition() -> Vector2:
	var cam = get_viewport().get_camera_2d()
	if cam:
		return cam.get_global_mouse_position()
	else:
		return get_viewport().get_mouse_position()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var mouseGlobalPosition = getMouseCamPosition()
			if ball.global_position.distance_to(mouseGlobalPosition) < 32:
				dragging = true
				dragStart = mouseGlobalPosition
		else:
			if dragging:
				dragging = false
				var mouseGlobalPosition = getMouseCamPosition()
				var force = dragStart - mouseGlobalPosition
				ball.apply_force(force * 150.0)
	elif event is InputEventMouseMotion and dragging:
		var mouseGlobalPosition = getMouseCamPosition()
		line.clear_points()
		line.add_point(ball.global_position)
		line.add_point(mouseGlobalPosition)
		
func _physics_process(delta: float) -> void:
	if !dragging:
		line.clear_points()
