extends Sprite3D

@export var adjacent: Array[Node3D]
var active = false

func _ready() -> void:
	$Area3D.connect("input_event", _on_clicked)
	$Area3D.input_ray_pickable = true
	
	_apply_texture()
	texture_changed.connect(_apply_texture)


func _apply_texture():
	var shader_material : ShaderMaterial = material_override
	shader_material.set_shader_parameter("sprite_texture", texture)

func _on_clicked(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		active = !active
		material_override.set_shader_parameter("active", active)
