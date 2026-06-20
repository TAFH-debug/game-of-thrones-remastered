class_name HouseBaratheon
extends House

func _init() -> void:
	super(&"baratheon", Enums.House.BARATHEON)

func get_deck() -> Array[HouseCard]:
	return [
		HouseCard.new(          &"stannis_baratheon", "baratheon", 4, 0, 0),
		WinTiesHouseCard.new(   &"melisandre",        "baratheon", 0, 0, 0),
		StealPowerHouseCard.new(&"davos_seaworth",    "baratheon", 1, 1, 0),
		HouseCard.new(          &"renly_baratheon",   "baratheon", 3, 0, 0),
		HouseCard.new(          &"brienne",           "baratheon", 2, 0, 0),
		HouseCard.new(          &"robert_baratheon",  "baratheon", 3, 0, 1),
		HouseCard.new(          &"salladhor_saan",    "baratheon", 1, 0, 0),
	]
