class_name CancelOrdersHouseCard
extends HouseCard

## If winner, cancel opponent's march orders in adjacent areas.
func collect_choices(battle: Battle, as_attacker: bool, attacker_wins: bool, server: GameServer) -> Array:
	var is_winner := (as_attacker and attacker_wins) or (not as_attacker and not attacker_wins)
	if not is_winner:
		return []
	var winner := battle.attacker if as_attacker else battle.defender
	var loser  := battle.defender if as_attacker else battle.attacker
	if winner == null or loser == null:
		return []
	var march_orders := server._get_player_march_orders(loser.id)
	if march_orders.is_empty():
		return []
	var choice := CancelOrdersChoice.new()
	choice.player_id = winner.id
	choice.ctx = {"orders": march_orders, "enemy": loser.id}
	return [choice]
