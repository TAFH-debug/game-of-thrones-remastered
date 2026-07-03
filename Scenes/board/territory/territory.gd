@tool
#class_name Territory
extends Node3D

signal clicked(territory: Node3D)

@export var data: TerritoryDataResource:
	set(value):
		data = value
		if territory_info:
			territory_info.data = data
			#print(name + " gave territory_info data in set()")

@onready var territory_info: TerritoryInfo = $TerritoryInfo

var _selected: bool = false

func _ready() -> void:
	if data:
		if data.area_type != TerritoryDataResource.AreaType.PORT:
			territory_info.data = data
			#print(name + " gave territory_info data in _ready")
		else:
			territory_info.visible = false

	var area: Area3D = get_node_or_null("Area3D")
	if area != null:
		area.input_event.connect(_on_area_input_event)

	var mesh_inst := get_node_or_null("Area3D/HighlightMesh") as MeshInstance3D
	if mesh_inst:
		mesh_inst.visible = false


func set_selected(value: bool) -> void:
	_selected = value
	var mesh_inst := get_node_or_null("Area3D/HighlightMesh") as MeshInstance3D
	if mesh_inst:
		mesh_inst.visible = _selected


func _on_ownership_changed(territory_id: StringName, house_id: StringName) -> void:
	if territory_id == data.territory_id:
		territory_info.change_owner(house_id)

func _on_area_input_event(
	_camera: Node,
	event: InputEvent,
	_event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
	) -> void:
	if event is InputEventMouseButton && (event.pressed && event.button_index == 1):
		if clicked.get_connections().size() > 0:
			clicked.emit(self)
		else:
			set_selected(not _selected)
