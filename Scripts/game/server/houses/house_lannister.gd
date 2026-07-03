class_name HouseLannister
extends House

func _init() -> void:
	super(&"lannister", Enums.House.LANNISTER)

func get_deck() -> Array[HouseCard]:
	return [
		TywinLannisterHouseCard.new(  &"tywin_lannister",   "lannister", 4, 0, 0),
		HouseCard.new(                &"ser_gregor_clegane","lannister", 3, 3, 0),
		HouseCard.new(                &"the_hound",         "lannister", 2, 0, 2),
		HouseCard.new(                &"jaime_lannister",   "lannister", 2, 1, 0),
		TyrionLannisterHouseCard.new( &"tyrion_lannister",  "lannister", 1, 0, 0),
		SerKevanHouseCard.new(        &"ser_kevan",         "lannister", 1, 0, 0),
		CerseiLannisterHouseCard.new( &"cersei_lannister",  "lannister", 0, 0, 0),
	]
