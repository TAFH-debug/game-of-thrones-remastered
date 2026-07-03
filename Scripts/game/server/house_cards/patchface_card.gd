class_name PatchfaceHouseCard
extends HouseCard

## After combat, look at the opponent's hand and discard one card of your choice.
func collect_choices(battle: Battle, as_attacker: bool, _attacker_wins: bool, _server: GameServer) -> Array:
	var opponent := battle.defender if as_attacker else battle.attacker
	if opponent == null or opponent.house_cards.is_empty():
		return []
	var opts: Array[Dictionary] = []
	for card: HouseCard in opponent.house_cards:
		opts.append({"id": str(card.id)})
	var player := battle.attacker if as_attacker else battle.defender
	var choice := PatchfaceChoice.new()
	choice.player_id = player.id
	choice.ctx = {"opts": opts, "opponent_id": opponent.id}
	return [choice]
