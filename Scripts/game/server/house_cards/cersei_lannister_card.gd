class_name CerseiLannisterHouseCard
extends HouseCard

## If you win, remove one of the opponent's Order tokens from anywhere on the board.
func collect_choices(battle: Battle, as_attacker: bool, attacker_wins: bool, server: GameServer) -> Array:
	var is_winner := (as_attacker and attacker_wins) or (not as_attacker and not attacker_wins)
	if not is_winner:
		return []
	var player := battle.attacker if as_attacker else battle.defender
	var loser  := battle.defender if as_attacker else battle.attacker
	if player == null or loser == null:
		return []
	var all_orders: Array[Dictionary] = []
	for o: Order in server.orders:
		if o.owner.id == loser.id:
			all_orders.append({"territory": o.territory, "type": OrderTypes.find_key(o.type)})
	if all_orders.is_empty():
		return []
	var choice := RemoveOrderChoice.new()
	choice.player_id = player.id
	choice.ctx = {"adjacent": all_orders}
	return [choice]
