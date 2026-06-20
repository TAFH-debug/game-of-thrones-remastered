class_name WesterosWinterIsComingCard
extends WesterosCard

func resolve(server: GameServer) -> void:
	server.westeros_deck.reshuffle(deck)
	var replacement: WesterosCard = server.westeros_deck.draw_one(deck)
	if replacement != null:
		replacement.resolve(server)
	else:
		server._advance_westeros_phase()
