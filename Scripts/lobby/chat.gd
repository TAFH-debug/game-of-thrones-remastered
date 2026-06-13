extends Node
class_name Chat

signal on_message(nickname: String, message: String)

@rpc("authority", "call_local")
func add_message(nickname: String, message: String):
	on_message.emit(nickname, message)
	
@rpc("any_peer", "call_local")
func send_message(message: String):
	if multiplayer.is_server():
		var player = Multiplayer.lobby.get_player_by_id(multiplayer.get_remote_sender_id())
		add_message.rpc(player.nickname, message)
