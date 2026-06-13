extends Area3D

@export var adjacent: Array[Node3D]
var active = false
var units = []
var barrels: int = 0
var mustering_power = 0
var can_be_selected = false

func _ready() -> void:
	connect("input_event", _on_clicked)
	input_ray_pickable = true
	
func _on_clicked(camera, event, position, normal, shape_idx):
	var pressed = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	if pressed and can_be_selected:
		print("Selected ", name)
