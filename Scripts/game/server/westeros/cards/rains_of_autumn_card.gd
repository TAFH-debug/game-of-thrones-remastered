class_name WesterosRainsOfAutumnCard
extends WesterosCard

func resolve(server: GameServer) -> void:
	for player: GamePlayerData in server.players:
		player.power += player.supply
		server._client_events.player_power_updated.rpc(player.id, player.power)
	server._advance_westeros_phase()
