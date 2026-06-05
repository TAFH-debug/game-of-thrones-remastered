extends Label

func update():
	text = ""
	for i in Multiplayer.lobby.players:
		text += i.nickname + "\n"

func _process(delta: float) -> void:
	update()
