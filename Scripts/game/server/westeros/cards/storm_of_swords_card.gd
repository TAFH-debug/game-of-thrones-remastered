class_name WesterosStormOfSwordsCard
extends WesterosCard

func resolve(server: GameServer) -> void:
	server._remove_orders_of_type(OrderType.TYPE_SUPPORT)
	server._advance_westeros_phase()
