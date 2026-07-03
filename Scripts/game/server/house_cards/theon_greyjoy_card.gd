class_name TheonGreyjoyHouseCard
extends HouseCard

## +1 CS and a sword icon when defending a Castle or Stronghold.
func on_revealed(battle: Battle, as_attacker: bool, _server: GameServer) -> void:
	if as_attacker:
		return
	if battle.territory.has_fortification():
		battle.defender_extra_cs += 1
		battle.defender_extra_swords += 1
