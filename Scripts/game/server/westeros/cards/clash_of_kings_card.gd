class_name WesterosClashOfKingsCard
extends WesterosCard

var bidding_track: int = 0

func _init(p_name: StringName, p_deck: int, p_track: int) -> void:
	super(p_name, p_deck)
	bidding_track = p_track

func resolve(server: GameServer) -> void:
	server._continuation = GameServer.Continuation.WESTEROS_PHASE
	server.start_bidding(bidding_track)

func to_dict() -> Dictionary:
	var d := super()
	d["bidding_track"] = bidding_track
	return d
