class_name HouseGreyjoy
extends House

func _init() -> void:
	super(&"greyjoy", Enums.House.GREYJOY)

func get_deck() -> Array[HouseCard]:
	return [
		HouseCard.new(               &"euron_crows_eye",   "greyjoy", 4, 1, 0),
		VictarionGreyjoyHouseCard.new(&"victarion_greyjoy","greyjoy", 3, 0, 0),
		TheonGreyjoyHouseCard.new(   &"theon_greyjoy",     "greyjoy", 2, 0, 0),
		BalonGreyjoyHouseCard.new(   &"balon_greyjoy",     "greyjoy", 2, 0, 0),
		AshaGreyjoyHouseCard.new(    &"asha_greyjoy",      "greyjoy", 1, 0, 0),
		HouseCard.new(               &"dagmer_cleftjaw",   "greyjoy", 1, 1, 1),
		AeronDamphairHouseCard.new(  &"aeron_damphair",    "greyjoy", 0, 0, 0),
	]
