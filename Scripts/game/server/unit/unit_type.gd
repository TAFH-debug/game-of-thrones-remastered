class_name UnitType

func get_attack_power(unit: Unit, target_territory_id: String) -> int:
	return 1

func get_defence_power(unit: Unit, territory_id: String) -> int:
	return 1

func can_move_to_land() -> bool:
	return true

func can_move_to_sea() -> bool:
	return false
