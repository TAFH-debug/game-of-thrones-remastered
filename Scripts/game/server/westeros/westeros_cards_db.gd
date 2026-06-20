class_name WesterosCardsDB

static func get_deck(num: int) -> Array[WesterosCard]:
	match num:
		1: return _deck1()
		2: return _deck2()
		3: return _deck3()
	return []

static func _deck1() -> Array[WesterosCard]:
	return [
		WesterosGameOfThronesCard.new(&"game_of_thrones_1", 1),
		WesterosWinterIsComingCard.new(&"winter_is_coming_1", 1),
		WesterosClashOfKingsCard.new( &"clash_kings_court",  1, GameServer.KINGS_COURT),
		WesterosThroneOfBladesCard.new(&"throne_of_blades",  1),
		WesterosSeaOfStormsCard.new(  &"sea_of_storms",      1),
		WesterosRainsOfAutumnCard.new(&"rains_of_autumn",    1),
	]

static func _deck2() -> Array[WesterosCard]:
	return [
		WesterosGameOfThronesCard.new(&"game_of_thrones_2", 2),
		WesterosWinterIsComingCard.new(&"winter_is_coming_2", 2),
		WesterosClashOfKingsCard.new( &"clash_fiefdoms",     2, GameServer.FIEFDOMS),
		WesterosSupplyCard.new(       &"supply",             2),
		WesterosStormOfSwordsCard.new(&"storm_of_swords",    2),
		WesterosDarkWingsCard.new(    &"dark_wings",         2),
	]

static func _deck3() -> Array[WesterosCard]:
	return [
		WesterosWinterIsComingCard.new(&"winter_is_coming_3", 3),
		WesterosClashOfKingsCard.new( &"clash_iron_throne",  3, GameServer.IRON_THRONE),
		WesterosWildlingAttackCard.new(&"wildling_attack",   3),
		WesterosMusterCard.new(       &"muster",             3),
		WesterosFamineCard.new(       &"famine",             3),
		WesterosCard.new(             &"calm",               3),
	]
