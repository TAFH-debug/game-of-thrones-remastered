class_name HouseTyrell
extends House

func _init() -> void:
	super(&"tyrell", Enums.House.TYRELL)

func get_deck() -> Array[HouseCard]:
	return [
		HouseCard.new(              &"mace_tyrell",     "tyrell", 4, 0, 0),
		RemoveOrderHouseCard.new(   &"queen_of_thorns", "tyrell", 0, 0, 0),
		HouseCard.new(              &"garlan_tyrell",   "tyrell", 3, 1, 0),
		PreventRetreatHouseCard.new(&"randyll_tarly",   "tyrell", 3, 0, 0),
		HouseCard.new(              &"loras_tyrell",    "tyrell", 2, 0, 0),
		HouseCard.new(              &"ser_hobber",      "tyrell", 1, 0, 0),
		HouseCard.new(              &"paxter_redwyne",  "tyrell", 2, 0, 1),
	]
