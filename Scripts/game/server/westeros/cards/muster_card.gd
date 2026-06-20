class_name WesterosMusterCard
extends WesterosCard

func resolve(server: GameServer) -> void:
	server._start_muster_phase()
