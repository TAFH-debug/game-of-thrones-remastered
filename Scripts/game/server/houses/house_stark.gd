class_name HouseStark
extends House

func _init() -> void:
	super(&"stark", Enums.House.STARK)

func get_deck() -> Array[HouseCard]:
	return [
		HouseCard.new(             &"eddard_stark",   "stark", 4, 2, 0),
		HouseCard.new(             &"robb_stark",     "stark", 3, 0, 0),
		RecycleOnLossHouseCard.new(&"roose_bolton",   "stark", 2, 0, 0),
		HouseCard.new(             &"greatjon_umber", "stark", 2, 1, 0),
		HouseCard.new(             &"rodrik_cassel",  "stark", 1, 0, 2),
		BlackfishHouseCard.new(    &"the_blackfish",  "stark", 1, 0, 0),
		CatelynStarkHouseCard.new( &"catelyn_stark",  "stark", 0, 0, 0),
	]
