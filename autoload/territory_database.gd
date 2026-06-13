class_name TerritoryDatabase
extends Node

const TERRITORY_DIR := "res://data/territories/"

# Keyed by StringName territory_id, e.g. &"BoI"
var _territories: Dictionary = {}

func _ready() -> void:
	_load_all()

func _load_all() -> void:
	var dir := DirAccess.open(TERRITORY_DIR)
	if dir == null:
		push_error("TerritoryDatabase: directory not found: " + TERRITORY_DIR)
		return

	dir.list_dir_begin()
	var file := dir.get_next()
	while file != "":
		if file.ends_with(".tres"):
			var res: TerritoryDataResource = load(TERRITORY_DIR + file)
			if res:
				_territories[res.territory_id] = res
		file = dir.get_next()
	dir.list_dir_end()

	print("TerritoryDB: loaded %d territories" % _territories.size())

# ── PUBLIC API ────────────────────────────────────────────────────────────────

func get_territory(id: StringName) -> TerritoryDataResource:
	return _territories.get(id, null)

func all() -> Array[TerritoryDataResource]:
	return _territories.values()

func ids() -> Array:
	return _territories.keys()

func get_adjacent_lands(id: StringName) -> Array[TerritoryDataResource]:
	var t := get_territory(id)
	if t == null:
		return []
	var result: Array[TerritoryDataResource] = []
	for adj_id in t.adjacent_lands:
		var adj := get_territory(adj_id)
		if adj:
			result.append(adj)
	return result

func get_adjacent_seas(id: StringName) -> Array[TerritoryDataResource]:
	var t := get_territory(id)
	if t == null:
		return []
	var result: Array[TerritoryDataResource] = []
	for adj_id in t.adjacent_seas:
		var adj := get_territory(adj_id)
		if adj:
			result.append(adj)
	return result
