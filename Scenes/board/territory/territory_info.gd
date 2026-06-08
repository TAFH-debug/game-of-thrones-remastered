@tool
class_name TerritoryInfo
extends Node3D

@export var territory_name: String
@export var supply_count: int = 0
@export var power_count: int = 0
@export var data: TerritoryData:
	set(value):
		data = value
		if not is_node_ready():
			return
		update()
		#print("\t" + name + " updated in set()")

@onready var name_label: Label = %NameLabel
@onready var owner_icon: TextureRect = $SubViewport/OwnerIcon
@onready var sub_viewport: SubViewport = $SubViewport

@onready var s: MarginContainer = $SubViewport/MarginContainer/Panel/HBox/Supply
@onready var s2: MarginContainer = $SubViewport/MarginContainer/Panel/HBox/Supply2
@onready var c: MarginContainer = $SubViewport/MarginContainer/Panel/HBox/Crown
@onready var c2: MarginContainer = $SubViewport/MarginContainer/Panel/HBox/Crown2

func update() -> void:
	name_label.text = data.territory_name
	s.visible = data.supply_count >= 1
	s2.visible = data.supply_count >= 2
	c.visible = data.power_count >= 1
	c2.visible = data.power_count >= 2
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func _on_data_changed() -> void:
	if data:
		update()

func change_owner(p_territory_owner: StringName = &"None") -> void:
	var atlas_id: int = 0
	var x_offset: int = 0
	
	match p_territory_owner:
		"Neutral":		atlas_id = 1
		"Tyrell":		atlas_id = 2
		"Martell":		atlas_id = 3
		"Baratheon":	atlas_id = 4
		"Lannister":	atlas_id = 5
		"Greyjoy":		atlas_id = 6
		"Stark":		atlas_id = 7
		"Arryn":		atlas_id = 8
		"Sosun":		atlas_id = 9
		"Frikadelka":	atlas_id = 10
		_:
			atlas_id = 0
			x_offset = -15
	
	owner_icon.texture.region = Rect2(x_offset + atlas_id * 94.0, 0, 94, 109)
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
