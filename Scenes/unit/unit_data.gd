class_name UnitData
extends Resource

enum UnitType { FOOTMAN, KNIGHT, SIEGE_ENGINE, SHIP }

@export var unit_type: UnitType
## Depends on UnitType
@export_range(0,4) var siege_bonus: int
@export_range(1,2) var mustering_cost: int
@export var can_move_on_land: bool
@export var can_move_on_sea: bool
@export var can_retreat: bool

func _init(
	p_unit_type: UnitType = UnitType.FOOTMAN,
	p_siege_bonus: int = 0,
	p_mustering_cost: int = 1,
	p_can_move_on_land: bool = true,
	p_can_move_on_sea: bool = false,
	p_can_retreat: bool = true
) -> void:
	unit_type = p_unit_type
	siege_bonus = p_siege_bonus
	mustering_cost = p_mustering_cost
	can_move_on_land = p_can_move_on_land
	can_move_on_sea = p_can_move_on_sea
	can_retreat = p_can_retreat
	
func _validate_property(property: Dictionary) -> void:
	if property.name == "combat_strength":
		property.usage |= PROPERTY_USAGE_READ_ONLY
		
func get_combat_strength() -> int:
	match unit_type:
		UnitType.FOOTMAN:      return 1
		UnitType.KNIGHT:       return 2
		UnitType.SIEGE_ENGINE: return 0
		UnitType.SHIP:         return 1
		_:                     return 0
