extends VBoxContainer

@export var labelScene: PackedScene

func _ready():
	Multiplayer.lobby.on_player_connected.connect(update)
	Multiplayer.lobby.on_player_disconnected.connect(update)
	update(null)

func update(_player_data):
	for child in get_children():
		if child is Label:
			continue
		child.queue_free()

	for player in Multiplayer.lobby.players:
		var label = labelScene.instantiate()
		label.set_data(player)
		add_child(label)
