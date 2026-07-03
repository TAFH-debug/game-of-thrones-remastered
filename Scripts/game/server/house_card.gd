class_name HouseCard

var id: StringName
var house: String
var combat_strength: int = 0
var sword_icons: int = 0
var fortification_icons: int = 0

func _init(
	p_id: StringName = &"",
	p_house: String = "",
	p_combat_strength: int = 0,
	p_sword_icons: int = 0,
	p_fortification_icons: int = 0
) -> void:
	id = p_id
	house = p_house
	combat_strength = p_combat_strength
	sword_icons = p_sword_icons
	fortification_icons = p_fortification_icons

## Called when both cards are revealed. Override for immediate reveal effects.
func on_revealed(_battle: Battle, _as_attacker: bool, _server: GameServer) -> void:
	pass

## True if this card wins all ties in combat.
func wins_ties() -> bool:
	return false

## True if opponent must play a card; auto-win if opponent has none.
func forces_card() -> bool:
	return false

## True if losing survivors are eliminated instead of retreating.
func prevents_retreat() -> bool:
	return false

## True if this card's owner takes no casualties from swords or card abilities.
func prevents_casualties() -> bool:
	return false

## Return BattleChoice objects requiring player input after card reveal.
func collect_choices(_battle: Battle, _as_attacker: bool, _attacker_wins: bool, _server: GameServer) -> Array:
	return []

## Apply immediate post-choice effects (power drains, recycle, etc.).
func on_finish(_battle: Battle, _as_attacker: bool, _attacker_wins: bool, _server: GameServer) -> void:
	pass

func to_dict() -> Dictionary:
	return {
		"id": str(id),
		"house": house,
		"combat_strength": combat_strength,
		"sword_icons": sword_icons,
		"fortification_icons": fortification_icons,
	}
