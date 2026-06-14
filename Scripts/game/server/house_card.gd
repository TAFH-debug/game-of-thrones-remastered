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

func to_dict() -> Dictionary:
	return {
		"id": str(id),
		"house": house,
		"combat_strength": combat_strength,
		"sword_icons": sword_icons,
		"fortification_icons": fortification_icons
	}
