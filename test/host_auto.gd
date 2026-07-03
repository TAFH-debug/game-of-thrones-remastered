extends Node

func _ready() -> void:
	print("HOSTAUTO: hosting")
	PlayerSettings.nickname = "HostGuy"
	Multiplayer.lobby.host()
	var probe := preload("res://test/probe.gd").new()
	probe.tag = "HOST"
	get_tree().root.add_child.call_deferred(probe)
	await get_tree().create_timer(6.0).timeout
	print("HOSTAUTO: lobby players=", Multiplayer.lobby.players.size(), " -> ready")
	Multiplayer.lobby.set_ready.rpc(true)
