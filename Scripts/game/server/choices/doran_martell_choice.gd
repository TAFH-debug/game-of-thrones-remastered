class_name DoranMartellChoice
extends BattleChoice

func prompt(events: ClientEvents) -> void:
	events.prompt_card_choice.rpc_id(player_id, BattleChoice.TypeId.DORAN_PLAN, "", [])

func apply(server: GameServer, data: Dictionary) -> bool:
	var track_idx := clampi(data.get("track", 0), 0, 2)
	var opponent_id: int = ctx.get("opponent_id", -1)
	var track: InfluenceTrack = server.influence_tracks[track_idx]
	var pos := track.get_position(opponent_id)
	if pos != -1:
		track.arr.remove_at(pos)
		track.arr.append(opponent_id)  # Move to last (bottom) position
	server._update_tokens()
	return true
