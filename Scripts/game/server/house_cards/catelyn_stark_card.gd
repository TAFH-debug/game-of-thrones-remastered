class_name CatelynStarkHouseCard
extends HouseCard

## If defending with a Defence order in this territory, its bonus is doubled.
func on_revealed(battle: Battle, as_attacker: bool, _server: GameServer) -> void:
	if as_attacker:
		return
	if battle.territory.defend_bonus > 0:
		battle.territory.defend_bonus *= 2
