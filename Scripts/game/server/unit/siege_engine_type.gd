extends UnitType
class_name SiegeEngineType

const SIEGE_BONUS := 4

func get_attack_power(unit: Unit, target_territory_id: String) -> int:
	var res: TerritoryDataResource = TerritoryDB.get_territory(target_territory_id)
	if res and res.fortification != TerritoryDataResource.Fortification.NONE:
		return SIEGE_BONUS
	return 0

func get_defence_power(unit: Unit, territory_id: String) -> int:
	return 0
