class_name OrderTypes

static var order_types = {
	'M0': MarshOrderType.new(),
	'M+': MarshOrderType.new(1),
	'M-': MarshOrderType.new(-1)
}

static func get_type(key: String):
	return order_types.get(key)
	
