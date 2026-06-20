class_name ValyrianBladeChoice
extends BattleChoice

func prompt(events: ClientEvents) -> void:
	events.prompt_valyrian_blade.rpc_id(player_id, ctx.get("territory", ""))

func apply(server: GameServer, data: Dictionary) -> bool:
	if data.get("use", false) and server.current_battle != null:
		var p := server.get_player(player_id)
		if p and p.has_valyrian_blade and not p.valyrian_blade_used:
			p.valyrian_blade_used = true
			if server.current_battle.attacker.id == player_id:
				server.current_battle.attacker_extra_swords += 1
			else:
				server.current_battle.defender_extra_swords += 1
	server._resolve_battle()
	return false  # battle starts its own choice queue
