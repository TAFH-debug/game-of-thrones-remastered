class_name HouseBaratheon
extends House

func _init() -> void:
	super(&"baratheon", Enums.House.BARATHEON)

func get_deck() -> Array[HouseCard]:
	return [
		StannisBaratheonHouseCard.new(&"stannis_baratheon", "baratheon", 4, 0, 0),
		RenlyBaratheonHouseCard.new(  &"renly_baratheon",   "baratheon", 3, 0, 0),
		DavosSeaworthHouseCard.new(   &"davos_seaworth",    "baratheon", 2, 0, 0),
		HouseCard.new(                &"brienne",           "baratheon", 2, 1, 1),
		HouseCard.new(                &"melisandre",        "baratheon", 1, 1, 0),
		SalladhorSaanHouseCard.new(   &"salladhor_saan",    "baratheon", 1, 0, 0),
		PatchfaceHouseCard.new(       &"patchface",         "baratheon", 0, 0, 0),
	]
