class_name PatchfaceChoice
extends BattleChoice

func prompt(events: ClientEvents) -> void:
	events.prompt_card_choice.rpc_id(player_id, BattleChoice.TypeId.PATCHFACE, "", ctx.get("opts", []))

func apply(server: GameServer, data: Dictionary) -> bool:
	var card_id: StringName = StringName(str(data.get("card_id", "")))
	var opponent := server.get_player(ctx.get("opponent_id", -1))
	if opponent == null:
		return true
	for i in opponent.house_cards.size():
		if opponent.house_cards[i].id == card_id:
			var card := opponent.house_cards[i]
			opponent.house_cards.remove_at(i)
			opponent.used_cards.append(card)
			break
	return true
