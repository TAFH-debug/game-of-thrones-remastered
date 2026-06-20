class_name HouseCardsDB

# All 7 house cards per house (42 total).
# ability_id constants (matched in GameServer._handle_card_ability):
#   "win_ties"         – your card wins all ties in this combat
#   "force_card"       – opponent must play a card; if none remain, you auto-win
#   "recycle_cards"    – after combat return all your used cards to hand
#   "negate_card"      – opponent's card ability text is negated this combat
#   "kill_unit"        – kill one opponent unit regardless of combat outcome (choice)
#   "remove_order"     – remove one adjacent opponent order token (choice)
#   "cancel_orders"    – if you win, cancel opponent march orders in adjacent areas (choice)
#   "enemy_loses_power"– if you win, opponent loses ability_params["amount"] power tokens
#   "steal_power"      – if you win, take 1 power token from opponent
#   "prevent_retreat"  – losing player cannot retreat; survivors are eliminated
#   "doran_plan"       – after combat, move any house one step on any influence track (choice)

static func get_deck(house: int) -> Array[HouseCard]:
	match house:
		Enums.House.STARK:      return _stark()
		Enums.House.LANNISTER:  return _lannister()
		Enums.House.BARATHEON:  return _baratheon()
		Enums.House.GREYJOY:    return _greyjoy()
		Enums.House.TYRELL:     return _tyrell()
		Enums.House.MARTELL:    return _martell()
	return []

static func _c(id: StringName, house: String, cs: int, s: int, f: int,
		ability: StringName = &"", params: Dictionary = {}) -> HouseCard:
	var card := HouseCard.new(id, house, cs, s, f)
	card.ability_id = ability
	card.ability_params = params
	return card

static func _stark() -> Array[HouseCard]:
	return [
		_c(&"grey_wind",      "stark", 0, 2, 0, &"win_ties"),
		_c(&"robb_stark",     "stark", 3, 1, 0),
		_c(&"catelyn_stark",  "stark", 3, 0, 1, &"force_card"),
		_c(&"greatjon_umber", "stark", 3, 0, 0),
		_c(&"rodrik_cassel",  "stark", 2, 0, 0),
		_c(&"roose_bolton",   "stark",-1, 0, 0, &"recycle_cards"),
		_c(&"eddard_stark",   "stark", 4, 0, 0),
	]

static func _lannister() -> Array[HouseCard]:
	return [
		_c(&"tywin_lannister",  "lannister", 4, 0, 0, &"enemy_loses_power", {"amount": 2}),
		_c(&"cersei_lannister", "lannister", 0, 0, 0, &"cancel_orders"),
		_c(&"tyrion_lannister", "lannister", 0, 0, 0, &"negate_card"),
		_c(&"the_mountain",     "lannister", 3, 0, 0, &"kill_unit"),
		_c(&"sandor_clegane",   "lannister", 3, 1, 0),
		_c(&"jaime_lannister",  "lannister", 3, 0, 1),
		_c(&"ser_kevan",        "lannister", 2, 0, 0),
	]

static func _baratheon() -> Array[HouseCard]:
	return [
		_c(&"stannis_baratheon", "baratheon", 4, 0, 0),
		_c(&"melisandre",        "baratheon", 0, 0, 0, &"win_ties"),
		_c(&"davos_seaworth",    "baratheon", 1, 1, 0, &"steal_power"),
		_c(&"renly_baratheon",   "baratheon", 3, 0, 0),
		_c(&"brienne",           "baratheon", 2, 0, 0),
		_c(&"robert_baratheon",  "baratheon", 3, 0, 1),
		_c(&"salladhor_saan",    "baratheon", 1, 0, 0),
	]

static func _greyjoy() -> Array[HouseCard]:
	return [
		_c(&"balon_greyjoy",    "greyjoy", 4, 0, 0, &"prevent_retreat"),
		_c(&"aeron_damphair",   "greyjoy", 0, 0, 0, &"recycle_cards"),
		_c(&"asha_greyjoy",     "greyjoy", 1, 0, 0),
		_c(&"euron_crows_eye",  "greyjoy", 3, 0, 0, &"enemy_loses_power", {"amount": 1}),
		_c(&"theon_greyjoy",    "greyjoy", 2, 1, 0),
		_c(&"dagmer_cleftjaw",  "greyjoy", 2, 0, 0),
		_c(&"victarion_greyjoy","greyjoy", 3, 0, 1),
	]

static func _tyrell() -> Array[HouseCard]:
	return [
		_c(&"mace_tyrell",     "tyrell", 4, 0, 0),
		_c(&"queen_of_thorns", "tyrell", 0, 0, 0, &"remove_order"),
		_c(&"garlan_tyrell",   "tyrell", 3, 1, 0),
		_c(&"randyll_tarly",   "tyrell", 3, 0, 0, &"prevent_retreat"),
		_c(&"loras_tyrell",    "tyrell", 2, 0, 0),
		_c(&"ser_hobber",      "tyrell", 1, 0, 0),
		_c(&"paxter_redwyne",  "tyrell", 2, 0, 1),
	]

static func _martell() -> Array[HouseCard]:
	return [
		_c(&"doran_martell",   "martell", 0, 0, 0, &"doran_plan"),
		_c(&"nymeria_sand",    "martell", 0, 1, 0, &"force_card"),
		_c(&"obara_sand",      "martell", 2, 1, 0),
		_c(&"arianne_martell", "martell", 2, 0, 0),
		_c(&"the_red_viper",   "martell", 4, 0, 0, &"kill_unit"),
		_c(&"ser_gerris",      "martell", 1, 0, 0),
		_c(&"areo_hotah",      "martell", 2, 0, 1),
	]
