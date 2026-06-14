class_name Unit

var territory: String
var owner: int
var type: UnitType
var type_key: String = "F"

func _init() -> void:
	pass

func to_dict() -> Dictionary:
	return {
		"territory": territory,
		"owner": owner,
		"type": type_key
	}
