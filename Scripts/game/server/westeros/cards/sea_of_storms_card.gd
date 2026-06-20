class_name WesterosSeaOfStormsCard
extends WesterosCard

func resolve(server: GameServer) -> void:
	server._remove_orders_of_type(OrderType.TYPE_RAID)
	server._advance_westeros_phase()
