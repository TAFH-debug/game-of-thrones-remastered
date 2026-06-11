extends Camera3D

const PLANE := Plane(Vector3.UP, 0)
const RAY_LENGTH := 100.0

@export var drag_sensitivity: float = 1.0
@export var draggable_area: AABB = AABB(
	Vector3(-12.0, 0.0, -30),
	Vector3(24.0, 0.0, 40))
@export_range(-12, 12, 0.05) var z_center_offset: float = 0.25

@export_range(0.0, 6.7) var zoom_speed: float = 2.0
@export_range(0.3, 25) var zoom_min: float = 2.0
@export_range(0.3, 25) var zoom_max: float = 11.0
@export var zoom_smoothness: float = 8.0

var _is_dragging := false
var _drag_start_world := Vector3.ZERO
var _target_zoom: float

func _ready() -> void:
	assert(zoom_min <= zoom_max, "are you stupid? maybe make zoom_min less than zoom_max, just a suggestion")
	_target_zoom = position.y

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_drag"):
		_is_dragging = true
		_drag_start_world = _get_floor_point()
		Input.set_default_cursor_shape(Input.CURSOR_DRAG)
	elif event.is_action_released("camera_drag"):
		_is_dragging = false
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
	if event.is_action_pressed("camera_zoom_in"):
		_target_zoom = clamp(_target_zoom - zoom_speed, zoom_min, zoom_max)
	elif event.is_action_pressed("camera_zoom_out"):
		_target_zoom = clamp(_target_zoom + zoom_speed, zoom_min, zoom_max)
	
	if event is InputEventMouseMotion and _is_dragging:
		var current_world := _get_floor_point()
		if current_world != Vector3.ZERO and _drag_start_world != Vector3.ZERO:
			position += (_drag_start_world - current_world) * drag_sensitivity
			_drag_start_world = _get_floor_point()

func _process(delta: float) -> void:
	position.y = lerp(position.y, _target_zoom, zoom_smoothness * delta)
	
	var zoom_t := inverse_lerp(zoom_min, zoom_max, position.y)
	
	var max_x_range: float = lerp(draggable_area.size.x * 0.5, 0.0, zoom_t)
	var center_x := draggable_area.position.x + draggable_area.size.x * 0.5
	position.x = clampf(position.x, center_x - max_x_range, center_x + max_x_range)
	
	# arbitrary ahh numbers mumbo jumbo vv
	var max_z_range: float = lerp(draggable_area.size.z * 0.5, 0.0, zoom_t)
	var center_z := draggable_area.position.z + draggable_area.size.z * 0.5 + z_center_offset
	position.z = clampf(position.z, center_z - max_z_range, draggable_area.end.z)
	

func _get_floor_point() -> Vector3:
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_from := project_ray_origin(mouse_pos)
	var ray_to := ray_from + project_ray_normal(mouse_pos) * RAY_LENGTH
	var hit = PLANE.intersects_ray(ray_from, ray_to)
	return hit if hit else Vector3.ZERO
