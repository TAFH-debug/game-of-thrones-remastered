class_name TywinLannisterHouseCard
extends HouseCard

## If you win this combat, gain two Power tokens.
func on_finish(battle: Battle, as_attacker: bool, attacker_wins: bool, server: GameServer) -> void:
	var is_winner := (as_attacker and attacker_wins) or (not as_attacker and not attacker_wins)
	if not is_winner:
		return
	var winner := battle.attacker if as_attacker else battle.defender
	if winner == null:
		return
	winner.power += 2
	server._client_events.player_power_updated.rpc(winner.id, winner.power)
