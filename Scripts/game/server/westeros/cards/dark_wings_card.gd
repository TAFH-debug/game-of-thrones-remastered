class_name WesterosDarkWingsCard
extends WesterosCard

func resolve(server: GameServer) -> void:
	# Raven notification already goes out via prompt_messenger_raven in _begin_planning_phase
	server._advance_westeros_phase()
