class_name StealPowerHouseCard
extends HouseCard

## If winner, steal 1 power token from opponent.
func on_finish(battle: Battle, as_attacker: bool, attacker_wins: bool, server: GameServer) -> void:
	var is_winner := (as_attacker and attacker_wins) or (not as_attacker and not attacker_wins)
	if not is_winner:
		return
	var winner := battle.attacker if as_attacker else battle.defender
	var loser  := battle.defender if as_attacker else battle.attacker
	if winner == null or loser == null:
		return
	var stolen := mini(1, loser.power)
	loser.power -= stolen
	winner.power += stolen
	server._client_events.player_power_updated.rpc(loser.id, loser.power)
	server._client_events.player_power_updated.rpc(winner.id, winner.power)
