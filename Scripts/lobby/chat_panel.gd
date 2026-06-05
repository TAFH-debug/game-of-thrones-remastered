extends VBoxContainer

@export var message_scene: PackedScene

func _ready():
	Multiplayer.lobby.chat.on_message.connect(_on_message)
	$InputConatiner/Button.pressed.connect(_on_pressed)
	
func _on_message(nickname: String, message: String):
	var message_comp = message_scene.instantiate()
	message_comp.get_node("Label").text = nickname + ": " + message
	$MarginContainer/VBoxContainer.add_child(message_comp)

func _on_pressed():
	var text = $InputConatiner/LineEdit.text
	Multiplayer.lobby.chat.send_message.rpc(text)
