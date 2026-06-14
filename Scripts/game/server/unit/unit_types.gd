class_name UnitTypes

static var unit_types: Dictionary = {
	"FM": FootmanType.new(),
	"KN":  KnightType.new(),
	"SH":  ShipType.new(),
	"SE": SiegeEngineType.new()
}

static func get_type(key: String) -> UnitType:
	return unit_types.get(key)
