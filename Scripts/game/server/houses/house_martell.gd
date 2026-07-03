class_name HouseMartell
extends House

func _init() -> void:
	super(&"martell", Enums.House.MARTELL)

func get_deck() -> Array[HouseCard]:
	return [
		HouseCard.new(            &"the_red_viper",  "martell", 4, 2, 1),
		HouseCard.new(            &"areo_hotah",     "martell", 3, 0, 1),
		HouseCard.new(            &"obara_sand",     "martell", 2, 1, 0),
		HouseCard.new(            &"darkstar",       "martell", 2, 1, 0),
		NymeriaSandHouseCard.new( &"nymeria_sand",   "martell", 1, 0, 0),
		ArianneMartellHouseCard.new(&"arianne_martell","martell",1, 0, 0),
		DoranMartellHouseCard.new(&"doran_martell",  "martell", 0, 0, 0),
	]
