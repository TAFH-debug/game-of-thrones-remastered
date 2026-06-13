class_name OrderType

var action_name: String = ""

func execute(order: Order, ctx: Dictionary) -> void:
	pass

func is_valid(order: Order, ctx: Dictionary) -> bool:
	return true
