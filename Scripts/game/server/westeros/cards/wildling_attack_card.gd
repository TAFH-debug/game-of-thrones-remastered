class_name WesterosWildlingAttackCard
extends WesterosCard

func resolve(server: GameServer) -> void:
	server._start_wildling_attack()
