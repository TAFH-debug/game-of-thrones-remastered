class_name WesterosSupplyCard
extends WesterosCard

func resolve(server: GameServer) -> void:
	server._update_supply()
	server._advance_westeros_phase()
