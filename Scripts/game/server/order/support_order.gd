extends OrderType
class_name SupportOrderType

var bonus: int = 0

func _init(b: int = 0) -> void:
	bonus = b
	action_name = "support"

func get_type() -> String:
	return OrderType.TYPE_SUPPORT

# Support is passive — handled automatically during battle resolution
func is_valid(order: Order, ctx: Dictionary, server: GameServer) -> bool:
	return true

func execute(order: Order, ctx: Dictionary, server: GameServer) -> void:
	pass
