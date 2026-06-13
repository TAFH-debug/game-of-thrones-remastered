class_name Enums

enum House {
	LANNISTER,
	GREYJOY,
	STARK,
	MARTELL,
	TYRELL,
	BARATHEON
}
	
static func get_house_name(house: House):
	match (house):
		House.LANNISTER:
			return "Lannister"
		House.BARATHEON:
			return "Baratheon"
		House.TYRELL:
			return "Tyrell"
		House.GREYJOY:
			return "Greyjoy"
		House.MARTELL:
			return "Martell"
		House.STARK:
			return "Stark"
	return "House not found"
