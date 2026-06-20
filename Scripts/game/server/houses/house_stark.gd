class_name HouseStark
extends House

func _init() -> void:
	super(&"stark", Enums.House.STARK)

func get_deck() -> Array[HouseCard]:
	return [
		WinTiesHouseCard.new(   &"grey_wind",      "stark",  0, 2, 0),
		HouseCard.new(          &"robb_stark",      "stark",  3, 1, 0),
		ForceCardHouseCard.new( &"catelyn_stark",   "stark",  3, 0, 1),
		HouseCard.new(          &"greatjon_umber",  "stark",  3, 0, 0),
		HouseCard.new(          &"rodrik_cassel",   "stark",  2, 0, 0),
		RecycleCardsHouseCard.new(&"roose_bolton",  "stark", -1, 0, 0),
		HouseCard.new(          &"eddard_stark",    "stark",  4, 0, 0),
	]
