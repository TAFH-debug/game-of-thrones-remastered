class_name BalonGreyjoyHouseCard
extends HouseCard

## The printed combat strength of the opponent's House card is reduced to 0.
func on_revealed(battle: Battle, as_attacker: bool, _server: GameServer) -> void:
	if as_attacker:
		battle.defender_cs_is_zero = true
	else:
		battle.attacker_cs_is_zero = true
