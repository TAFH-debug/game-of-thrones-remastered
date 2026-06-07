class_name HouseCardData
extends Resource

enum AbilityTrigger { NONE, ON_WIN, ON_LOSS, IMMEDIATE, CONDITIONAL }

@export var card_name: String
@export var card_id: StringName
@export var house_id: StringName 
@export_range(0, 67) var combat_strength: int
@export_range(0, 2) var sword_icons: int
@export_range(0, 2) var fortification_icons: int
@export var ability_desc: String
@export var ability_trigger: AbilityTrigger

func _init(
	p_card_name: String = "",
	p_card_id: StringName = &"",
	p_house_id: StringName = &"",
	p_combat_strength: int = 0,
	p_sword_icons: int = 0,
	p_fortification_icons: int = 0,
	p_ability_desc: String = "",
	p_ability_trigger: AbilityTrigger = AbilityTrigger.NONE
) -> void:
	card_name = p_card_name
	card_id = p_card_id
	house_id = p_house_id
	combat_strength = p_combat_strength
	sword_icons = p_sword_icons
	fortification_icons = p_fortification_icons
	ability_desc = p_ability_desc
	ability_trigger = p_ability_trigger
