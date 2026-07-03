class_name ArianneMartellHouseCard
extends HouseCard

## If defending and losing, the attacker cannot move units into the embattled area.
func on_finish(battle: Battle, as_attacker: bool, attacker_wins: bool, _server: GameServer) -> void:
	if as_attacker:
		return
	if attacker_wins:
		battle.prevent_attacker_advance = true
