class_name AshaGreyjoyHouseCard
extends HouseCard

## If NOT being supported, gain two sword icons and one fortification icon.
func on_revealed(battle: Battle, as_attacker: bool, _server: GameServer) -> void:
	var my_support := battle.attacker_support if as_attacker else battle.defender_support
	if my_support > 0:
		return
	if as_attacker:
		battle.attacker_extra_swords += 2
		battle.attacker_extra_forts += 1
	else:
		battle.defender_extra_swords += 2
		battle.defender_extra_forts += 1
