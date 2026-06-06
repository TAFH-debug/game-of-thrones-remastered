extends Node3D
class_name TerritoryInfo

@export var territory_name: String = ""
@export var territory_owner: String = ""
@export var supplies: int = 0
@export var crowns: int = 0

@onready var name_label: Label = %NameLabel
@onready var owner_icon: TextureRect = $SubViewport/OwnerIcon
@onready var sub_viewport: SubViewport = $SubViewport

@onready var s: MarginContainer = $SubViewport/MarginContainer/PanelContainer/HBoxContainer/SuppliesAndCrowns/Supply
@onready var s2: MarginContainer = $SubViewport/MarginContainer/PanelContainer/HBoxContainer/SuppliesAndCrowns/Supply2
@onready var c: MarginContainer = $SubViewport/MarginContainer/PanelContainer/HBoxContainer/SuppliesAndCrowns/Crown
@onready var c2: MarginContainer = $SubViewport/MarginContainer/PanelContainer/HBoxContainer/SuppliesAndCrowns/Crown2

func _ready() -> void:
	name_label.text = territory_name
	
	s.visible = supplies >= 1
	s2.visible = supplies >= 2
	c.visible = crowns >= 1
	c2.visible = crowns >= 2
	
	change_owner(territory_owner)
	
func change_owner(p_territory_owner: String = "None") -> void:
	var atlas_id: int = 0
	var x_offset: int = -7
	
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
		_:				atlas_id = 0
	
	owner_icon.texture.region = Rect2(x_offset + atlas_id * 94.0, 0, 94, 109)
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
