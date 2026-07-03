class_name RenlyBaratheonHouseCard
extends HouseCard

## If you win, upgrade one of your participating Footmen to a Knight.
func collect_choices(battle: Battle, as_attacker: bool, attacker_wins: bool, _server: GameServer) -> Array:
	var is_winner := (as_attacker and attacker_wins) or (not as_attacker and not attacker_wins)
	if not is_winner:
		return []
	var player := battle.attacker if as_attacker else battle.defender
	if player == null:
		return []
	var units := battle.attacking_units if as_attacker else battle.territory.units
	var footmen: Array[Dictionary] = []
	for i in units.size():
		if units[i].type_key == "F" and units[i].owner == player.id:
			footmen.append({"index": i})
	if footmen.is_empty():
		return []
	var choice := RenlyUpgradeChoice.new()
	choice.player_id = player.id
	choice.ctx = {"footmen": footmen, "as_attacker": as_attacker}
	return [choice]
