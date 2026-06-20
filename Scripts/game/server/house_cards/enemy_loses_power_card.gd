class_name EnemyLosesPowerHouseCard
extends HouseCard

var amount: int = 1

func _init(p_id: StringName, p_house: String, p_cs: int, p_s: int, p_f: int, p_amount: int = 1) -> void:
	super(p_id, p_house, p_cs, p_s, p_f)
	amount = p_amount

## If winner, opponent loses `amount` power tokens.
func on_finish(battle: Battle, as_attacker: bool, attacker_wins: bool, server: GameServer) -> void:
	var is_winner := (as_attacker and attacker_wins) or (not as_attacker and not attacker_wins)
	if not is_winner:
		return
	var loser := battle.defender if as_attacker else battle.attacker
	if loser == null:
		return
	loser.power = maxi(0, loser.power - amount)
	server._client_events.player_power_updated.rpc(loser.id, loser.power)
