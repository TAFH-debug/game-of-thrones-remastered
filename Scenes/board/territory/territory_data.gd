class_name TerritoryData
extends Resource

enum AreaType { LAND, SEA, PORT }
enum Fortification { NONE, CASTLE, STRONGHOLD }

@export var territory_name: String = ""
@export var territory_id: StringName = &""
@export var area_type: AreaType = AreaType.LAND
@export var fortification: Fortification = Fortification.NONE
@export_range(0,2) var supply_count: int = 0
@export_range(0,2) var power_count: int = 0
@export var is_home_area: bool = false
@export var home_house: StringName = &""
@export_range(-1,6) var neutral_force_strength: int = 0
@export var adjacent_lands: Array[StringName] = []
@export var adjacent_seas: Array[StringName] = []
@export var connected_port: StringName = &""
@export var connected_land: StringName = &""

func _init(
	p_territory_id: StringName = &"",
	p_territory_name: String = "",
	p_area_type: AreaType = AreaType.LAND,
	p_fortification: Fortification = Fortification.NONE,
	p_supply_count: int = 0,
	p_power_count: int = 0,
	p_is_home_area: bool = false,
	p_home_house: StringName = &"",
	p_neutral_force_strength: int = 0,
	p_adjacent_lands: Array[StringName] = [],
	p_adjacent_seas: Array[StringName] = [],
	p_connected_port: StringName = &"",
	p_connected_land: StringName = &""
) -> void:
	territory_id = p_territory_id
	territory_name = p_territory_name
	area_type = p_area_type
	fortification = p_fortification
	supply_count = p_supply_count
	power_count = p_power_count
	is_home_area = p_is_home_area
	home_house = p_home_house
	neutral_force_strength = p_neutral_force_strength
	adjacent_lands = p_adjacent_lands
	adjacent_seas = p_adjacent_seas
	connected_port = p_connected_port
	connected_land = p_connected_land
