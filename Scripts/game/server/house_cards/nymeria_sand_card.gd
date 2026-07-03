class_name NymeriaSandHouseCard
extends HouseCard

## Gains a fortification icon when defending; gains a sword icon when attacking.
func on_revealed(battle: Battle, as_attacker: bool, _server: GameServer) -> void:
	if as_attacker:
		battle.attacker_extra_swords += 1
	else:
		battle.defender_extra_forts += 1
