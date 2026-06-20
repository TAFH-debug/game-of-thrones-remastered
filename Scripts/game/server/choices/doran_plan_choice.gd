class_name DoranPlanChoice
extends BattleChoice

func prompt(events: ClientEvents) -> void:
	events.prompt_card_choice.rpc_id(player_id, BattleChoice.TypeId.DORAN_PLAN, "", [])

func apply(server: GameServer, data: Dictionary) -> bool:
	var track_idx := clampi(data.get("track", 0), 0, 2)
	var target_pid: int = data.get("player", -1)
	var direction := signi(data.get("direction", 1))
	var track: InfluenceTrack = server.influence_tracks[track_idx]
	var pos := track.get_position(target_pid)
	if pos != -1:
		var new_pos := clampi(pos + direction, 0, track.arr.size() - 1)
		track.arr.remove_at(pos)
		track.arr.insert(new_pos, target_pid)
	server._update_tokens()
	return true
