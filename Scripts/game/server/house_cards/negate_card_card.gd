class_name NegateCardHouseCard
extends HouseCard

## Negate the opponent's card ability the moment both cards are revealed.
func on_revealed(battle: Battle, as_attacker: bool) -> void:
	if as_attacker:
		battle.defender_card_negated = true
	else:
		battle.attacker_card_negated = true
