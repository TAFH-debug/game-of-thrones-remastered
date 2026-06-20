class_name RemoveOrderHouseCard
extends HouseCard

## Remove one adjacent opponent order token regardless of combat outcome.
func collect_choices(battle: Battle, as_attacker: bool, _attacker_wins: bool, server: GameServer) -> Array:
	var player := battle.attacker if as_attacker else battle.defender
	if player == null:
		return []
	var adj := server._get_adjacent_orders(battle.territory.get_id(), player.id)
	if adj.is_empty():
		return []
	var choice := RemoveOrderChoice.new()
	choice.player_id = player.id
	choice.ctx = {"adjacent": adj}
	return [choice]
