extends Camera2D
## Camera and movement controller for the player

@export var move_speed = 200
@export var zoom_speed = 0.1
@export var min_zoom = 0.5
@export var max_zoom = 3.0
@export var pan_speed = 500

var can_pan = false
var pan_start = Vector2.ZERO

func _ready():
	zoom = Vector2.ONE * 1.5
	set_physics_process(true)

func _physics_process(delta):
	handle_movement(delta)
	handle_zoom()
	handle_pan(delta)

func handle_movement(delta):
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir:
		global_position += input_dir * move_speed * delta

func handle_zoom():
	if Input.is_action_just_released("zoom_in"):
		zoom = zoom.lerp(Vector2.ONE * zoom, 1 - zoom_speed)
		zoom = zoom.clamp(Vector2.ONE * min_zoom, Vector2.ONE * max_zoom)
	elif Input.is_action_just_released("zoom_out"):
		zoom = zoom.lerp(Vector2.ONE / zoom, 1 - zoom_speed)
		zoom = zoom.clamp(Vector2.ONE * min_zoom, Vector2.ONE * max_zoom)

func handle_pan(_delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		if not can_pan:
			pan_start = get_global_mouse_position()
			can_pan = true
		var pan_delta = pan_start - get_global_mouse_position()
		global_position += pan_delta * (1.0 / zoom.x)
	else:
		can_pan = false
