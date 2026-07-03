class_name AeronDamphairChoice
extends BattleChoice

func prompt(events: ClientEvents) -> void:
	events.prompt_card_choice.rpc_id(player_id, BattleChoice.TypeId.AERON_DAMPHAIR, "", _typed_options("opts"))

func apply(server: GameServer, data: Dictionary) -> bool:
	var battle := server.current_battle
	if battle == null:
		server._check_both_cards_submitted()
		return false
	if not data.get("swap", false):
		server._check_both_cards_submitted()
		return false
	var player := server.get_player(player_id)
	if player == null or player.power < 2 or player.house_cards.is_empty():
		server._check_both_cards_submitted()
		return false
	player.power -= 2
	server._client_events.player_power_updated.rpc(player_id, player.power)
	var is_attacker: bool = ctx.get("as_attacker", true)
	if is_attacker and battle.attacker_card != null:
		player.house_cards.append(battle.attacker_card)
		player.used_cards.erase(battle.attacker_card)
		battle.attacker_card = null
	elif not is_attacker and battle.defender_card != null:
		player.house_cards.append(battle.defender_card)
		player.used_cards.erase(battle.defender_card)
		battle.defender_card = null
	server._client_events.select_house_card.rpc_id(
		player_id, battle.territory.get_id(), player.available_card_ids()
	)
	return false
