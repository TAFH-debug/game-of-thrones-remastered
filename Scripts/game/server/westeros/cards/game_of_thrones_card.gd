class_name WesterosGameOfThronesCard
extends WesterosCard

func resolve(server: GameServer) -> void:
	for player: GamePlayerData in server.players:
		var gained := 0
		for t: GameTerritory in server.get_controlled_territories(player.id):
			if t.resource.power_count > 0:
				gained += 1
		if gained > 0:
			player.power += gained
			server._client_events.player_power_updated.rpc(player.id, player.power)
	server._advance_westeros_phase()
