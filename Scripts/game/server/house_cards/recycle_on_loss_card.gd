class_name RecycleOnLossHouseCard
extends HouseCard

## If you LOSE this combat, return your entire discard pile to hand (incl. this card).
func on_finish(battle: Battle, as_attacker: bool, attacker_wins: bool, _server: GameServer) -> void:
	var i_won := (as_attacker and attacker_wins) or (not as_attacker and not attacker_wins)
	if i_won:
		return
	var player := battle.attacker if as_attacker else battle.defender
	if player != null:
		player.recycle_used_cards()
