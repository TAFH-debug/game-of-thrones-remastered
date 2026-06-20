class_name DoranPlanHouseCard
extends HouseCard

## After combat, move any house one step on any influence track.
func collect_choices(battle: Battle, as_attacker: bool, _attacker_wins: bool, _server: GameServer) -> Array:
	var player := battle.attacker if as_attacker else battle.defender
	if player == null:
		return []
	var choice := DoranPlanChoice.new()
	choice.player_id = player.id
	choice.ctx = {}
	return [choice]
