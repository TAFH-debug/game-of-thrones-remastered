# DragCamera3D.gd
extends Camera3D

@export var drag_speed: float = 0.03
@export var pan_speed: float = 20.0
@export var zoom_speed: float = 5.0
@export var min_zoom: float = 2.0
@export var max_zoom: float = 50.0
@export var invert_drag: bool = false

var _is_dragging: bool = false
var _last_mouse_pos: Vector2 = Vector2.ZERO
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_zoom_in"):
		position.y = clamp(position.y - zoom_speed, min_zoom, max_zoom)

	if event.is_action_pressed("camera_zoom_out"):
		position.y = clamp(position.y + zoom_speed, min_zoom, max_zoom)

func _process(delta: float) -> void:
	if Input.is_action_pressed("camera_drag"):
		_is_dragging = true
		Input.set_default_cursor_shape(
			Input.CURSOR_DRAG
		)
	else:
		_is_dragging = false
		_last_mouse_pos = Vector2()
		Input.set_default_cursor_shape(
			Input.CURSOR_ARROW
		)
		
	if _is_dragging:
		var cur_pos = get_viewport().get_mouse_position()
		var delta_pos: Vector2 = cur_pos - _last_mouse_pos
		if _last_mouse_pos == Vector2():
			_last_mouse_pos = cur_pos
		else:		
			_last_mouse_pos = cur_pos	
			var direction: float = 1.0 if invert_drag else -1.0
			position.x += delta_pos.x * drag_speed * direction
			position.z += delta_pos.y * drag_speed * direction
	else:
		_last_mouse_pos = Vector2()
