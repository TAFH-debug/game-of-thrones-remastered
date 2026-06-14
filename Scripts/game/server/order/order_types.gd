class_name OrderTypes

static var order_types: Dictionary = {
	"M-":  MarchOrderType.new(-1),
	"M0":  MarchOrderType.new(0),
	"M+":  MarchOrderType.new(1),
	"S0":  SupportOrderType.new(0),
	"S+":  SupportOrderType.new(1),
	"R0":  RaidOrderType.new(false),
	"R+":  RaidOrderType.new(true),
	"C0":  ConsolidateOrderType.new(0),
	"C+":  ConsolidateOrderType.new(1),
	"D1":  DefendOrderType.new(1),
	"D2":  DefendOrderType.new(2)
}

static func get_type(key: String) -> OrderType:
	return order_types.get(key)

static func find_key(order_type: OrderType) -> String:
	for key: String in order_types:
		if order_types[key] == order_type:
			return key
	return ""
