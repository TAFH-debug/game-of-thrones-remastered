class_name SerKevanHouseCard
extends HouseCard

## If attacking, each participating Footman (incl. supporting Lannister Footmen) adds +2 CS instead of +1.
func on_revealed(battle: Battle, as_attacker: bool, _server: GameServer) -> void:
	if not as_attacker:
		return
	battle.attacker_footmen_attack_bonus += 1  # +1 extra on top of base 1 = +2 total
