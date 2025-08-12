extends Camera2D

@export var ballPath: NodePath
@export var lineDrawerPath: NodePath

@export var followZoom: float = 1.0
@export var navZoom: float = 1.6
@export var zoomSpeed: float = 8.0
@export var followSmooth: float = 8.0
@export var panSpeed: float = 1200.0
@export var velocityThreshold = 1.0

var ball: RigidBody2D = null
var lineDrawer: Node = null
var ballCam: Camera2D = null

var targetZoomValue: float

func _ready() -> void:
	if ballPath != null and has_node(ballPath):
		ball = get_node(ballPath) as RigidBody2D
		if ball and ball.has_node("Camera2D"):
			ballCam = ball.get_node("Camera2D") as Camera2D
			
	if lineDrawerPath != null and has_node(lineDrawerPath):
		lineDrawer = get_node(lineDrawerPath)
		
	if ballCam:
		ballCam.make_current()
		targetZoomValue = ballCam.zoom.x
	else:
		self.make_current()
		targetZoomValue = ballCam.zoom.x
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			setTargetZoom(targetZoomValue * 0.9)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			setTargetZoom(targetZoomValue * 1.1)
			
func setTargetZoom(z:float) -> void:
	targetZoomValue = clamp(z, 0.4, 3.0)
	
func _process(delta: float) -> void:
	if not ball:
		return
		
	var ballMoving : bool = ball.linear_velocity.length() > velocityThreshold
	var playerAiming := false
	
	if lineDrawer and lineDrawer.has_method("get"):
		if lineDrawer.has_meta("dragging"):
			playerAiming = bool(lineDrawer.get_meta("dragging"))
		else: 
			playerAiming = bool(lineDrawer.dragging)
			
	var shouldFollow := ballMoving or playerAiming
	
	if shouldFollow and ballCam:
		 #_______Follow Mode_______
		if not ballCam.is_current():
			global_position = ballCam.global_position
			zoom = Vector2(ballCam.zoom.x, ballCam.zoom.y)
			ballCam.make_current()
			targetZoomValue = ballCam.zoom.x
	else:
		#_______Nav Mode_______
		if not self.is_current():
			if ballCam:
				global_position = ball.global_position
				zoom = Vector2(ballCam.zoom.x, ballCam.zoom.y)
			self.make_current()
			
		var inputVec := Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		)
		if inputVec != Vector2.ZERO:
			global_position += inputVec.normalized() * panSpeed * delta
			
		targetZoomValue = navZoom
		
		var currentZ := zoom.x
		var newZ : float = lerp(currentZ, targetZoomValue, zoomSpeed * delta)
		zoom = Vector2(newZ, newZ)
	
