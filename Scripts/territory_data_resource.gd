class_name TerritoryDataResource
extends Resource

enum AreaType { LAND, SEA, PORT }
enum Fortification { NONE, CASTLE, STRONGHOLD }

@export var territory_name: String = ""
@export var territory_id: StringName = &""

@export_enum("LAND", "SEA", "PORT")
var area_type: int = AreaType.LAND

@export_enum("NONE", "CASTLE", "STRONGHOLD")
var fortification: int = Fortification.NONE

@export var supply_count: int = 0
@export var power_count: int = 0
@export var is_home_area: bool = false
@export var initial_neutral_force_strength: int = 0

@export var adjacent_lands: Array[StringName] = []
@export var adjacent_seas: Array[StringName] = []

@export var connected_port: StringName = &""
@export var connected_land: StringName = &""

@export var world_x: float = 0.0
@export var world_z: float = 0.0

@export var polygons: Array[PackedVector2Array] = []
