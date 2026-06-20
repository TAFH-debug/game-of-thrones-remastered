class_name House

var house_name: StringName = &""
var house_id: int = 0  # Enums.House value

func _init(p_name: StringName, p_id: int) -> void:
	house_name = p_name
	house_id = p_id

## Returns this house's 7 house cards. Override in each subclass.
func get_deck() -> Array[HouseCard]:
	return []
