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
	
	
	# TODO connect signal to change owner properly
	#game_server.territory_ownership_changed.connect(_on_ownership_changed)
	
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
		print("pressed LMB on area of territory: " + name)
