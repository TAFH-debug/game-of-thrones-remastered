class_name KillUnitHouseCard
extends HouseCard

## Kill one opponent unit regardless of combat outcome.
func collect_choices(battle: Battle, as_attacker: bool, _attacker_wins: bool, _server: GameServer) -> Array:
	if as_attacker:
		if battle.territory.units.is_empty():
			return []
		var opts: Array[Dictionary] = []
		for i in battle.territory.units.size():
			opts.append({"index": i, "type": battle.territory.units[i].type_key})
		var choice := KillUnitChoice.new()
		choice.player_id = battle.attacker.id
		choice.ctx = {"territory": battle.territory.get_id(), "opts": opts, "from_attacker": false}
		return [choice]
	else:
		if battle.attacking_units.is_empty():
			return []
		var opts: Array[Dictionary] = []
		for i in battle.attacking_units.size():
			opts.append({"index": i, "type": battle.attacking_units[i].type_key})
		var choice := KillUnitChoice.new()
		choice.player_id = battle.defender.id
		choice.ctx = {"territory": battle.territory.get_id(), "opts": opts, "from_attacker": true}
		return [choice]
