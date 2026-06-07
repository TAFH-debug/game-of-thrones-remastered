class_name UnitData
extends Resource

enum UnitType { FOOTMAN, KNIGHT, SIEGE_ENGINE, SHIP }

@export var unit_type: UnitType
@export_range(0,4) var combat_strength: int
@export var siege_bonus: int
@export_range(1,2) var supply_cost: int
@export var can_move_on_land: bool
@export var can_move_on_sea: bool

func _init(
	p_unit_type: UnitType = UnitType.FOOTMAN,
	p_combat_strength: int = 1,
	p_siege_bonus: int = 1,
	p_supply_cost: int = 1,
	p_can_move_on_land: bool = true,
	p_can_move_on_sea: bool = false
) -> void:
	unit_type = p_unit_type
	combat_strength = p_combat_strength
	siege_bonus = p_siege_bonus
	supply_cost = p_supply_cost
	can_move_on_land = p_can_move_on_land
	can_move_on_sea = p_can_move_on_sea
