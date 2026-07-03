class_name DoranMartellHouseCard
extends HouseCard

## Immediately move the opponent to the bottom of one Influence track of your choice.
func collect_choices(battle: Battle, as_attacker: bool, _attacker_wins: bool, _server: GameServer) -> Array:
	var player   := battle.attacker if as_attacker else battle.defender
	var opponent := battle.defender if as_attacker else battle.attacker
	if player == null or opponent == null:
		return []
	var choice := DoranMartellChoice.new()
	choice.player_id = player.id
	choice.ctx = {"opponent_id": opponent.id}
	return [choice]
