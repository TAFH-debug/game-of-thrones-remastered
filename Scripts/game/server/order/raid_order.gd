extends OrderType
class_name RaidOrderType

var is_special: bool = false

func _init(special: bool = false) -> void:
	is_special = special
	action_name = "raid"

func get_type() -> String:
	return OrderType.TYPE_RAID

func is_valid(order: Order, ctx: Dictionary, server: GameServer) -> bool:
	var target_id: String = ctx.get("territory", "")
	if target_id.is_empty():
		return true  # skip: remove token without raiding

	var from_t := server.get_territory(order.territory)
	var target_t := server.get_territory(target_id)
	if from_t == null or target_t == null:
		return false
	if not from_t.is_adjacent_to(target_t.get_id()):
		return false
	if target_t.order == null:
		return false
	if target_t.order.owner.id == order.owner.id:
		return false

	var target_type := target_t.order.type.get_type()
	var raidable := [OrderType.TYPE_CONSOLIDATE, OrderType.TYPE_SUPPORT, OrderType.TYPE_RAID]
	if is_special:
		raidable.append(OrderType.TYPE_DEFEND)

	return target_type in raidable

func execute(order: Order, ctx: Dictionary, server: GameServer) -> void:
	var target_id: String = ctx.get("territory", "")
	if target_id.is_empty():
		return  # skipped raid
	var target_t := server.get_territory(target_id)
	if target_t == null or target_t.order == null:
		return

	var raided := target_t.order
	server.orders.erase(raided)
	target_t.order = null

	server.notify_order_raided(order.owner, target_t)
