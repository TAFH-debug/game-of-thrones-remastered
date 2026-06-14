class_name OrderType

const TYPE_MARCH := "march"
const TYPE_SUPPORT := "support"
const TYPE_RAID := "raid"
const TYPE_CONSOLIDATE := "consolidate"
const TYPE_DEFEND := "defend"

var action_name: String = ""

func get_type() -> String:
	return ""

func execute(order: Order, ctx: Dictionary, server: GameServer) -> void:
	pass

func is_valid(order: Order, ctx: Dictionary, server: GameServer) -> bool:
	return true
