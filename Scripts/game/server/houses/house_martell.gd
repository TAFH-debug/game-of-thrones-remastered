class_name HouseMartell
extends House

func _init() -> void:
	super(&"martell", Enums.House.MARTELL)

func get_deck() -> Array[HouseCard]:
	return [
		DoranPlanHouseCard.new( &"doran_martell",   "martell", 0, 0, 0),
		ForceCardHouseCard.new( &"nymeria_sand",    "martell", 0, 1, 0),
		HouseCard.new(          &"obara_sand",      "martell", 2, 1, 0),
		HouseCard.new(          &"arianne_martell", "martell", 2, 0, 0),
		KillUnitHouseCard.new(  &"the_red_viper",   "martell", 4, 0, 0),
		HouseCard.new(          &"ser_gerris",      "martell", 1, 0, 0),
		HouseCard.new(          &"areo_hotah",      "martell", 2, 0, 1),
	]
