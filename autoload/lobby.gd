extends Node
class_name Lobby

enum States { LOBBY, INGAME }
signal on_player_connected(player_data: PlayerData)
signal on_player_disconnected(player_data: PlayerData)

var peer_connector: PeerConnector
var chat: Chat

var players: Array[PlayerData] = []
var state: States = States.LOBBY

func _ready():
	peer_connector = PeerConnector.new()
	chat = Chat.new()
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	add_child(peer_connector)
	add_child(chat)
	
func _on_peer_connected(id: int):
	if multiplayer.is_server():
		print("Player ", id, " connected")

func _on_peer_disconnected(id: int):
	if multiplayer.is_server():
		print("Player ", id, " disconnected")
		var player = players.find_custom(func(x: PlayerData): return id == x.id)
		var player_data = players[player]
		players.remove_at(player)
		on_player_disconnected.emit(player_data)

func join(ip: String, nickname: String):
	peer_connector.join_game(ip)
	multiplayer.connected_to_server.connect(func(): setup.rpc(nickname))

func host():
	peer_connector.host_game()
	setup(PlayerSettings.nickname)

func get_player_by_id(id: int) -> PlayerData:
	var player_idx = players.find_custom(func(x): return x.id == id)
	if player_idx == -1:
		return null
	return players[player_idx]
	
@rpc("any_peer")
func setup(nickname: String):
	if not multiplayer.is_server():
		return
		
	var player_data: PlayerData = PlayerData.new()
	var sender_id = multiplayer.get_remote_sender_id()
	player_data.id = sender_id if sender_id != 0 else multiplayer.get_unique_id()  # ✅
	player_data.nickname = nickname
	players_connected.rpc_id(sender_id, PlayerData.get_players_dict(players))
	player_connected.rpc(player_data.nickname, player_data.id)
	players.append(player_data)
	on_player_connected.emit(player_data)
	
@rpc("any_peer")
func set_nickname(nickname: String):
	var id = multiplayer.get_remote_sender_id()
	var player_idx = players.find_custom(func(x: PlayerData): return id == x.id)
	if player_idx == -1:
		return
	var player = players[player_idx]
	player.nickname = nickname
	
@rpc("any_peer", "call_local")
func set_ready(ready: bool):
	if not multiplayer.is_server():
		return
	var id = multiplayer.get_remote_sender_id()
	var player_idx = players.find_custom(func(x: PlayerData): return id == x.id)
	if player_idx == -1:
		return
	var player = players[player_idx]
	player.ready = ready
	player_ready.rpc(id, ready)

@rpc("authority")
func players_connected(players_arr: Array[Dictionary]):
	for pl in players_arr:
		var player_data = PlayerData.new()
		player_data.nickname = pl["nickname"]
		player_data.id = pl["id"]
		players.append(player_data)
		on_player_connected.emit(player_data)
	
@rpc("authority")
func player_connected(nickname: String, id: int):
	var player_data = PlayerData.new()
	player_data.nickname = nickname
	player_data.id = id
	players.append(player_data)
	on_player_connected.emit(player_data)
	
@rpc("authority", "call_local")
func player_ready(id: int, ready: bool):
	var player_idx = players.find_custom(func(x: PlayerData): return id == x.id)
	if player_idx == -1:
		return
	var player = players[player_idx]
	player.ready = ready
	on_player_connected.emit(player)
