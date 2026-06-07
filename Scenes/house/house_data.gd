class_name HouseData
extends Resource

@export var house_name: String  
@export var house_id: StringName:
	set(val):
		if val.length() > 3:
			push_warning("house_id '%s' exceeded 3 chars, truncated" % val)
		house_id = val.left(3)
@export var home_territories: Array[StringName]
@export var house_cards: Array[HouseCardData]
@export var starting_power: int
@export_range(0,5) var starting_iron_throne_position: int
@export_range(0,5) var starting_fiefdoms_position: int
@export_range(0,5) var starting_kings_court_position: int
@export var unit_color: Color

func _init(
	p_house_name: String = "",
	p_house_id: StringName = &"",
	p_home_territories: Array[StringName] = [],
	p_house_cards: Array[HouseCardData] = [],
	p_starting_power: int = 0,
	p_starting_iron_throne_position: int = 0,
	p_starting_fiefdoms_position: int = 0,
	p_starting_kings_court_position: int = 0,
	p_unit_color: Color = Color.WHITE
) -> void:
	house_name = p_house_name
	house_id = p_house_id
	home_territories = p_home_territories
	house_cards = p_house_cards
	starting_power = p_starting_power
	starting_iron_throne_position = p_starting_iron_throne_position
	starting_fiefdoms_position = p_starting_fiefdoms_position
	starting_kings_court_position = p_starting_kings_court_position
	unit_color = p_unit_color
