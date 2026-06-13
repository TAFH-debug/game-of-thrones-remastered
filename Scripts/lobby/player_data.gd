class_name PlayerData

var nickname: String = ""
var ready: bool = false
var id: int = 0
# Niggas in Paris

func get_dict():
	var dict = {}
	dict["nickname"] = self.nickname
	dict["ready"] = self.ready
	dict["id"] = self.id
	return dict
	
static func get_players_dict(players: Array[PlayerData]) -> Array[Dictionary]:
	var res: Array[Dictionary] = []
	for pl in players:
		res.append(pl.get_dict())
	return res
