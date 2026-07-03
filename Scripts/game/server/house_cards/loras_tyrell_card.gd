class_name LorasTyrellHouseCard
extends HouseCard

## If attacking and win, the March Order token moves into the conquered area and may resolve again.
func on_finish(battle: Battle, as_attacker: bool, attacker_wins: bool, server: GameServer) -> void:
	if not as_attacker or not attacker_wins or battle.march_origin == null:
		return
	var old_t := server.get_territory(battle.march_origin.territory)
	if old_t != null and old_t.order == battle.march_origin:
		old_t.order = null
	battle.march_origin.territory = str(battle.territory.get_id())
	battle.march_origin.resolved = false
	battle.territory.order = battle.march_origin
