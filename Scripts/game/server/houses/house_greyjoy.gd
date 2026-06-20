class_name HouseGreyjoy
extends House

func _init() -> void:
	super(&"greyjoy", Enums.House.GREYJOY)

func get_deck() -> Array[HouseCard]:
	return [
		PreventRetreatHouseCard.new(  &"balon_greyjoy",     "greyjoy", 4, 0, 0),
		RecycleCardsHouseCard.new(    &"aeron_damphair",    "greyjoy", 0, 0, 0),
		HouseCard.new(                &"asha_greyjoy",      "greyjoy", 1, 0, 0),
		EnemyLosesPowerHouseCard.new( &"euron_crows_eye",   "greyjoy", 3, 0, 0, 1),
		HouseCard.new(                &"theon_greyjoy",     "greyjoy", 2, 1, 0),
		HouseCard.new(                &"dagmer_cleftjaw",   "greyjoy", 2, 0, 0),
		HouseCard.new(                &"victarion_greyjoy", "greyjoy", 3, 0, 1),
	]
