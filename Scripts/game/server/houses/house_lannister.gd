class_name HouseLannister
extends House

func _init() -> void:
	super(&"lannister", Enums.House.LANNISTER)

func get_deck() -> Array[HouseCard]:
	return [
		EnemyLosesPowerHouseCard.new(&"tywin_lannister",  "lannister", 4, 0, 0, 2),
		CancelOrdersHouseCard.new(   &"cersei_lannister", "lannister", 0, 0, 0),
		NegateCardHouseCard.new(     &"tyrion_lannister", "lannister", 0, 0, 0),
		KillUnitHouseCard.new(       &"the_mountain",     "lannister", 3, 0, 0),
		HouseCard.new(               &"sandor_clegane",   "lannister", 3, 1, 0),
		HouseCard.new(               &"jaime_lannister",  "lannister", 3, 0, 1),
		HouseCard.new(               &"ser_kevan",        "lannister", 2, 0, 0),
	]
