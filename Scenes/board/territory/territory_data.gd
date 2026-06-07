@tool
class_name TerritoryData
extends Resource

enum AreaType { LAND, SEA, PORT }
enum Fortification {
	NONE,		## Provides 0 Mustering Points
	CASTLE,		## Proides 1 Mustering Point
	STRONGHOLD	## Provides 2 Mustering Points
	}

@export var territory_name: String
## Three Character ID of the territory, e.g. King's Landing - KsL
@export var territory_id: StringName:
	set(val):
		if val.length() > 3:
			push_warning("territory_id '%s' exceeded 3 chars, truncated" % val)
		territory_id = val.left(3)
		
@export var area_type: AreaType
@export var fortification: Fortification = Fortification.NONE
## Depends on Fortification
@export var mustering_points: int:
	get:
		match fortification:
			Fortification.CASTLE: return 1
			Fortification.STRONGHOLD: return 2
			_: return 0
@export_range(0,2) var supply_count: int
@export_range(0,2) var power_count: int
@export var is_home_area: bool
@export_range(0,6) var initial_neutral_force_strength: int
## 
@export var adjacent_lands: Array[StringName]
@export var adjacent_seas: Array[StringName]
@export var connected_port: StringName
@export var connected_land: StringName

func _init(
	p_territory_name: String = "None",
	p_territory_id: StringName = &"",
	p_area_type: AreaType = AreaType.LAND,
	p_fortification: Fortification = Fortification.NONE,
	p_supply_count: int = 0,
	p_power_count: int = 0,
	p_is_home_area: bool = false,
	p_initial_neutral_force_strength: int = 0,
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
	initial_neutral_force_strength = p_initial_neutral_force_strength
	adjacent_lands = p_adjacent_lands
	adjacent_seas = p_adjacent_seas
	connected_port = p_connected_port
	connected_land = p_connected_land
	
func _validate_property(property: Dictionary) -> void:
	if property.name == "mustering_points":
		property.usage |= PROPERTY_USAGE_READ_ONLY
