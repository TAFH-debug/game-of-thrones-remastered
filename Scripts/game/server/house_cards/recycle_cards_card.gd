class_name RecycleCardsHouseCard
extends HouseCard

func on_finish(battle: Battle, as_attacker: bool, _attacker_wins: bool, _server: GameServer) -> void:
	var player := battle.attacker if as_attacker else battle.defender
	if player != null:
		player.recycle_used_cards()
