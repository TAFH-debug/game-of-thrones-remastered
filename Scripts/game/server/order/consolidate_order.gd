extends OrderType
class_name ConsolidateOrderType

var bonus: int = 0

func _init(b: int = 0) -> void:
	bonus = b
	action_name = "consolidate"

func get_type() -> String:
	return OrderType.TYPE_CONSOLIDATE

func is_valid(order: Order, ctx: Dictionary, server: GameServer) -> bool:
	return true

func execute(order: Order, ctx: Dictionary, server: GameServer) -> void:
	var territory := server.get_territory(order.territory)
	if territory == null:
		return
	var gained := territory.resource.power_count + bonus
	order.owner.power += gained
	server.notify_consolidate(order.owner, territory, gained)
