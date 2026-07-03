class_name TyrionLannisterHouseCard
extends HouseCard

## Cancel the opponent's House card and return it to their hand; they must choose a different one.
func on_revealed(battle: Battle, as_attacker: bool, _server: GameServer) -> void:
	var opponent: GamePlayerData = battle.defender if as_attacker else battle.attacker
	if opponent == null:
		return
	var opponent_card: HouseCard = battle.defender_card if as_attacker else battle.attacker_card
	if opponent_card == null:
		return
	opponent.house_cards.append(opponent_card)
	opponent.used_cards.erase(opponent_card)
	if as_attacker:
		battle.defender_card = null
	else:
		battle.attacker_card = null
	battle.tyrion_fired = true
