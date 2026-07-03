class_name HouseTyrell
extends House

func _init() -> void:
	super(&"tyrell", Enums.House.TYRELL)

func get_deck() -> Array[HouseCard]:
	return [
		MaceTyrellHouseCard.new(   &"mace_tyrell",     "tyrell", 4, 0, 0),
		LorasTyrellHouseCard.new(  &"loras_tyrell",    "tyrell", 3, 0, 0),
		HouseCard.new(             &"garlan_tyrell",   "tyrell", 2, 2, 0),
		HouseCard.new(             &"randyll_tarly",   "tyrell", 2, 1, 0),
		HouseCard.new(             &"alester_florent", "tyrell", 1, 0, 1),
		HouseCard.new(             &"margaery_tyrell", "tyrell", 1, 0, 1),
		RemoveOrderHouseCard.new(  &"queen_of_thorns", "tyrell", 0, 0, 0),
	]
