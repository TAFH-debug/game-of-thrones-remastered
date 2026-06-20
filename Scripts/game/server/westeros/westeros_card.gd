class_name WesterosCard

var card_name: StringName = &""
var deck: int = 1

func _init(p_name: StringName, p_deck: int) -> void:
	card_name = p_name
	deck = p_deck

## Resolve this card's effect. Must eventually call server._advance_westeros_phase()
## (directly or after an async operation completes).
func resolve(server: GameServer) -> void:
	server._advance_westeros_phase()

func to_dict() -> Dictionary:
	return {"name": str(card_name), "deck": deck}
