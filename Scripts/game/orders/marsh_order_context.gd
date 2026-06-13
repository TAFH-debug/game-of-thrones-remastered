extends OrderContext
class_name MarshOrderContext

var territory: String

static func from_dict(params: Dictionary) -> MarshOrderContext:
	var ctx = MarshOrderContext.new()
	ctx.territory = params["territory"]
	return ctx
