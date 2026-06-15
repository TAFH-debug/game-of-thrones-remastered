@tool
#class_name Territory
extends Node3D

@export var data: TerritoryData:
	set(value):
		data = value
		if territory_info:
			territory_info.data = data
			#print(name + " gave territory_info data in set()")

@onready var territory_info: TerritoryInfo = $TerritoryInfo
@onready var _hover_mat: ShaderMaterial = ($Area3D/HighlightMesh as MeshInstance3D).material_override
@onready var _selected_mat: ShaderMaterial = _hover_mat.next_pass

var _selected: bool = false

func _ready() -> void:
	if data:
		if data.area_type != TerritoryData.AreaType.PORT:
			territory_info.data = data
			#print(name + " gave territory_info data in _ready")
		else:
			territory_info.visible = false

	var area: Area3D = get_node_or_null("Area3D")
	if area != null:
		area.input_event.connect(_on_area_input_event)
		area.mouse_entered.connect(func(): _set_hover(true))
		area.mouse_exited.connect(func(): _set_hover(false))
	_set_hover(false)
	_set_selected(false)
	#($Area3D/HighlightMesh as MeshInstance3D).visible = true

func _set_hover(value: bool) -> void:
	if _hover_mat:
		_hover_mat.set_shader_parameter("active", value)
func _set_selected(value: bool) -> void:
	_selected = value
	if _selected_mat:
		_selected_mat.set_shader_parameter("active", value)

func _on_ownership_changed(territory_id: StringName, house_id: StringName) -> void:
	if territory_id == data.territory_id:
		territory_info.change_owner(house_id)

func _on_area_input_event(_camera, event, _pos, _normal, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		print("pressed LMB on area of territory: " + name)
		_set_selected(not _selected)
