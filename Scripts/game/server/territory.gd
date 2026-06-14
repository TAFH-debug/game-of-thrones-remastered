class_name GameTerritory

var resource: TerritoryDataResource
var units: Array[Unit] = []
var controller: int = -1
var garrison: int = 0
var order: Order = null
var defend_bonus: int = 0

func _init(res: TerritoryDataResource) -> void:
	resource = res
	garrison = res.initial_neutral_force_strength

func get_id() -> StringName:
	return resource.territory_id

func is_adjacent_to(other_id: StringName) -> bool:
	return other_id in resource.adjacent_lands or other_id in resource.adjacent_seas

func get_attack_strength(target_id: String) -> int:
	var total := 0
	for unit: Unit in units:
		total += unit.type.get_attack_power(unit, target_id)
	return total

func get_defence_strength() -> int:
	var total := garrison + defend_bonus
	for unit: Unit in units:
		total += unit.type.get_defence_power(unit, resource.territory_id)
	return total

func has_fortification() -> bool:
	return resource.fortification != TerritoryDataResource.Fortification.NONE

func get_mustering_points() -> int:
	match resource.fortification:
		TerritoryDataResource.Fortification.CASTLE:     return 1
		TerritoryDataResource.Fortification.STRONGHOLD: return 2
	return 0

func clear_order() -> void:
	order = null
	defend_bonus = 0
