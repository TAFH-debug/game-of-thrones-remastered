extends OrderType
class_name DefendOrderType

var defence_bonus: int = 1

func _init(b: int = 1) -> void:
	defence_bonus = b
	action_name = "defend"

func get_type() -> String:
	return OrderType.TYPE_DEFEND

func is_valid(order: Order, ctx: Dictionary, server: GameServer) -> bool:
	return true

# Applied passively before action phase resolves marches
func execute(order: Order, ctx: Dictionary, server: GameServer) -> void:
	var territory := server.get_territory(order.territory)
	if territory:
		territory.defend_bonus = defence_bonus
