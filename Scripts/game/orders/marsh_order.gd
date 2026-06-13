extends OrderType
class_name MarshOrderType

var bonus = 0;

func _init(bonus: int = 0):
	self.bonus = bonus
	
func execute(order: Order, ctx_data: Dictionary) -> void:
	var ctx = MarshOrderContext.from_dict(ctx_data)
	var from = order.territory
	var to = ctx.territory
	
	# attack logic
	print("Attacked ", from, " to ", to)
	
func is_valid(order: Order, ctx_data: Dictionary) -> bool:
	var ctx = MarshOrderContext.from_dict(ctx_data)
	
	# check if adj
	
	# check land & water types

	return true
