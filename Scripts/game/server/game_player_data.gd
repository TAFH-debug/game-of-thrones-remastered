extends Node
class_name GamePlayerData

var id: int
var coins: int = 5
var power: int = 5
var supply: int = 0
var house: int = 0  # Enums.House value
var house_cards: Array[HouseCard] = []
var used_cards: Array[HouseCard] = []

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

func available_card_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for card: HouseCard in house_cards:
		ids.append(card.id)
	return ids
