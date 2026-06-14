extends UnitType
class_name KnightType

func get_attack_power(unit: Unit, target_territory_id: String) -> int:
	return 2

func get_defence_power(unit: Unit, territory_id: String) -> int:
	return 2
