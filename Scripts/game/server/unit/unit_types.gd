class_name UnitTypes

static var unit_types: Dictionary = {
	"F": FootmanType.new(),
	"K": KnightType.new(),
	"S": ShipType.new(),
	"SE": SiegeEngineType.new()
}

static func get_type(key: String) -> UnitType:
	return unit_types.get(key)
