class_name DavosSeaworthHouseCard
extends HouseCard

## +1 CS and a sword icon if Stannis Baratheon is in your discard pile.
func on_revealed(battle: Battle, as_attacker: bool, _server: GameServer) -> void:
	var player := battle.attacker if as_attacker else battle.defender
	if player == null:
		return
	var has_stannis := player.used_cards.any(func(c: HouseCard) -> bool:
		return c.id == &"stannis_baratheon")
	if not has_stannis:
		return
	if as_attacker:
		battle.attacker_extra_cs += 1
		battle.attacker_extra_swords += 1
	else:
		battle.defender_extra_cs += 1
		battle.defender_extra_swords += 1
