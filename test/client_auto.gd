extends Node

func _ready() -> void:
	print("CLIENTAUTO: joining")
	PlayerSettings.nickname = "ClientGuy"
	Multiplayer.lobby.join("127.0.0.1", PlayerSettings.nickname)
	var probe := preload("res://test/probe.gd").new()
	probe.tag = "CLIENT"
	get_tree().root.add_child.call_deferred(probe)
	await get_tree().create_timer(8.0).timeout
	print("CLIENTAUTO: lobby players=", Multiplayer.lobby.players.size(), " -> ready")
	Multiplayer.lobby.set_ready.rpc(true)
