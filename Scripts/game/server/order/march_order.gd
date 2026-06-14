extends OrderType
class_name MarchOrderType

var bonus: int = 0

func _init(b: int = 0) -> void:
	bonus = b
	action_name = "march"

func get_type() -> String:
	return OrderType.TYPE_MARCH

func is_valid(order: Order, ctx: Dictionary, server: GameServer) -> bool:
	var march_ctx := MarchOrderContext.from_dict(ctx)
	var from_t := server.get_territory(order.territory)
	var to_t := server.get_territory(march_ctx.territory)

	if from_t == null or to_t == null:
		return false
	if not from_t.is_adjacent_to(to_t.get_id()):
		return false

	var to_area := to_t.resource.area_type
	for type_key: String in march_ctx.units:
		var count: int = march_ctx.units[type_key]
		var unit_type := UnitTypes.get_type(type_key)
		if unit_type == null:
			return false
		if to_area == TerritoryDataResource.AreaType.SEA and not unit_type.can_move_to_sea():
			return false
		if to_area == TerritoryDataResource.AreaType.LAND and not unit_type.can_move_to_land():
			return false
		var available := from_t.units.filter(func(u: Unit) -> bool: return u.type_key == type_key)
		if available.size() < count:
			return false

	return true

func execute(order: Order, ctx: Dictionary, server: GameServer) -> void:
	var march_ctx := MarchOrderContext.from_dict(ctx)
	var from_t := server.get_territory(order.territory)
	var to_t := server.get_territory(march_ctx.territory)

	# Pick which units to move
	var moving: Array[Unit] = []
	for type_key: String in march_ctx.units:
		var needed: int = march_ctx.units[type_key]
		var moved := 0
		for unit: Unit in from_t.units:
			if unit.type_key == type_key and moved < needed:
				moving.append(unit)
				moved += 1

	for unit in moving:
		from_t.units.erase(unit)

	if from_t.units.is_empty():
		from_t.controller = -1

	server.notify_territory_changed(from_t)

	# Resolve destination
	if to_t.controller != -1 and to_t.controller != order.owner.id:
		server.start_battle(order.owner, to_t, moving, bonus)
	elif to_t.garrison > 0 and to_t.controller == -1:
		var atk := bonus
		for unit: Unit in moving:
			atk += unit.type.get_attack_power(unit, march_ctx.territory)
		if atk > to_t.garrison:
			for unit in moving:
				unit.territory = march_ctx.territory
				to_t.units.append(unit)
			to_t.garrison = 0
			to_t.controller = order.owner.id
			server.notify_territory_changed(to_t)
		else:
			# Failed to overcome garrison, units are lost
			pass
	else:
		for unit in moving:
			unit.territory = march_ctx.territory
			to_t.units.append(unit)
		to_t.controller = order.owner.id
		server.notify_territory_changed(to_t)
