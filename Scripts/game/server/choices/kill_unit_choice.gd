class_name KillUnitChoice
extends BattleChoice

func prompt(events: ClientEvents) -> void:
	events.prompt_card_choice.rpc_id(player_id, BattleChoice.TypeId.KILL_UNIT, "", ctx.get("opts", []))

func apply(server: GameServer, data: Dictionary) -> bool:
	var unit_idx: int = data.get("unit_index", -1)
	if ctx.get("from_attacker", false):
		if server.current_battle != null and unit_idx >= 0 and unit_idx < server.current_battle.attacking_units.size():
			server.current_battle.attacking_units.remove_at(unit_idx)
	else:
		var t := server.get_territory(ctx.get("territory", ""))
		if t != null and unit_idx >= 0 and unit_idx < t.units.size():
			t.units.remove_at(unit_idx)
			server.notify_territory_changed(t)
	return true
