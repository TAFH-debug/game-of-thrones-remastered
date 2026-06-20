class_name ThroneOfBladesChoice
extends BattleChoice

func prompt(events: ClientEvents) -> void:
	events.prompt_throne_of_blades.rpc_id(player_id)

func apply(server: GameServer, data: Dictionary) -> bool:
	match data.get("effect", "nothing"):
		"muster":
			server._start_muster_phase()
			return false
		"clash_iron_throne":
			server._continuation = GameServer.Continuation.WESTEROS_PHASE
			server.start_bidding(GameServer.IRON_THRONE)
			return false
		"clash_fiefdoms":
			server._continuation = GameServer.Continuation.WESTEROS_PHASE
			server.start_bidding(GameServer.FIEFDOMS)
			return false
		"clash_kings_court":
			server._continuation = GameServer.Continuation.WESTEROS_PHASE
			server.start_bidding(GameServer.KINGS_COURT)
			return false
	return true  # "nothing" → continue queue → _advance_westeros_phase
