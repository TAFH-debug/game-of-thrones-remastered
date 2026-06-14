class_name InfluenceTrack

# Player IDs in track order; index 0 = highest (first) position
var arr: Array[int] = []

func get_position(player_id: int) -> int:
	return arr.find(player_id)

func get_player_at(position: int) -> int:
	if position >= 0 and position < arr.size():
		return arr[position]
	return -1

# Returns true if player_a is ranked higher (lower index) than player_b
func is_higher_than(player_a: int, player_b: int) -> bool:
	var pos_a := get_position(player_a)
	var pos_b := get_position(player_b)
	if pos_a == -1:
		return false
	if pos_b == -1:
		return true
	return pos_a < pos_b

func reorder(bids: Dictionary) -> void:
	var original_positions: Dictionary = {}
	for i in arr.size():
		original_positions[arr[i]] = i

	arr.sort_custom(func(a: int, b: int) -> bool:
		var bid_a: int = bids.get(a, 0)
		var bid_b: int = bids.get(b, 0)
		if bid_a != bid_b:
			return bid_a > bid_b
		return original_positions.get(a, 999) < original_positions.get(b, 999)
	)
