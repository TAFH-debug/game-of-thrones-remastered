class_name WesterosFamineCard
extends WesterosCard

func resolve(server: GameServer) -> void:
	for player: GamePlayerData in server.players:
		player.power = maxi(0, player.power - 1)
		server._client_events.player_power_updated.rpc(player.id, player.power)
	server._advance_westeros_phase()
