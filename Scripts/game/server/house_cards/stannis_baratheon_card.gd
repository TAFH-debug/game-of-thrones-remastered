class_name StannisBaratheonHouseCard
extends HouseCard

## +1 CS if opponent is ranked higher on the Iron Throne influence track.
func on_revealed(battle: Battle, as_attacker: bool, server: GameServer) -> void:
	var me := battle.attacker if as_attacker else battle.defender
	var opponent := battle.defender if as_attacker else battle.attacker
	if me == null or opponent == null:
		return
	var track: InfluenceTrack = server.influence_tracks[GameServer.IRON_THRONE]
	if track.is_higher_than(opponent.id, me.id):
		if as_attacker:
			battle.attacker_extra_cs += 1
		else:
			battle.defender_extra_cs += 1
