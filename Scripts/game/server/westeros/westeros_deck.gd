class_name WesterosDeck

var _deck1: Array[WesterosCard] = []
var _deck2: Array[WesterosCard] = []
var _deck3: Array[WesterosCard] = []

func _init() -> void:
	reshuffle(1)
	reshuffle(2)
	reshuffle(3)

func reshuffle(num: int) -> void:
	match num:
		1: _deck1 = WesterosCardsDB.get_deck(1).duplicate(); _deck1.shuffle()
		2: _deck2 = WesterosCardsDB.get_deck(2).duplicate(); _deck2.shuffle()
		3: _deck3 = WesterosCardsDB.get_deck(3).duplicate(); _deck3.shuffle()

# Draw one card from each deck (refills automatically if exhausted)
func draw_three() -> Array[WesterosCard]:
	if _deck1.is_empty(): reshuffle(1)
	if _deck2.is_empty(): reshuffle(2)
	if _deck3.is_empty(): reshuffle(3)
	return [_deck1.pop_back(), _deck2.pop_back(), _deck3.pop_back()]

# Draw one replacement card from a specific deck (for Winter Is Coming)
func draw_one(num: int) -> WesterosCard:
	match num:
		1:
			if _deck1.is_empty(): reshuffle(1)
			return _deck1.pop_back()
		2:
			if _deck2.is_empty(): reshuffle(2)
			return _deck2.pop_back()
		3:
			if _deck3.is_empty(): reshuffle(3)
			return _deck3.pop_back()
	return null
