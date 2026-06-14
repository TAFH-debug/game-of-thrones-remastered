extends OrderContext
class_name MarchOrderContext

var territory: String
# type_key -> count, e.g. {"F": 2, "K": 1}
var units: Dictionary = {}

static func from_dict(params: Dictionary) -> MarchOrderContext:
	var ctx := MarchOrderContext.new()
	ctx.territory = params.get("territory", "")
	ctx.units = params.get("units", {})
	return ctx
