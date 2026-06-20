extends Node
class_name GamePlayerData

var id: int
var coins: int = 5
var power: int = 5
var supply: int = 0
var house: House = null
var house_cards: Array[HouseCard] = []
var used_cards: Array[HouseCard] = []

# Tokens — reassigned each planning phase from influence track positions
var has_iron_throne: bool = false
var has_valyrian_blade: bool = false
var has_messenger_raven: bool = false
var valyrian_blade_used: bool = false  # resets each westeros phase

# Wildling bidding
var wildling_vote: int = 0

func initialize_cards() -> void:
	house_cards = house.get_deck() if house != null else []
	used_cards = []

func get_card(card_id: StringName) -> HouseCard:
	for card: HouseCard in house_cards:
		if card.id == card_id:
			return card
	return null

func use_card(card_id: StringName) -> HouseCard:
	var card := get_card(card_id)
	if card:
		house_cards.erase(card)
		used_cards.append(card)
	return card

func recycle_used_cards() -> void:
	house_cards.append_array(used_cards)
	used_cards.clear()

func available_card_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for card: HouseCard in house_cards:
		ids.append(card.id)
	return ids

func to_dict() -> Dictionary:
	return {
		"id": id,
		"power": power,
		"supply": supply,
		"house": str(house.house_name) if house != null else "",
		"has_iron_throne": has_iron_throne,
		"has_valyrian_blade": has_valyrian_blade,
		"has_messenger_raven": has_messenger_raven,
	}
