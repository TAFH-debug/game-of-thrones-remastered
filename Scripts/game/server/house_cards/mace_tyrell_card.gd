class_name MaceTyrellHouseCard
extends HouseCard

## Immediately destroy one of the opponent's attacking or defending Footman units.
func collect_choices(battle: Battle, as_attacker: bool, _attacker_wins: bool, _server: GameServer) -> Array:
	if as_attacker:
		var footmen: Array[Dictionary] = []
		for i in battle.territory.units.size():
			if battle.territory.units[i].type_key == "F":
				footmen.append({"index": i, "type": "F"})
		if footmen.is_empty():
			return []
		var choice := KillUnitChoice.new()
		choice.player_id = battle.attacker.id
		choice.ctx = {"territory": battle.territory.get_id(), "opts": footmen, "from_attacker": false}
		return [choice]
	else:
		var footmen: Array[Dictionary] = []
		for i in battle.attacking_units.size():
			if battle.attacking_units[i].type_key == "F":
				footmen.append({"index": i, "type": "F"})
		if footmen.is_empty():
			return []
		var choice := KillUnitChoice.new()
		choice.player_id = battle.defender.id
		choice.ctx = {"opts": footmen, "from_attacker": true}
		return [choice]
