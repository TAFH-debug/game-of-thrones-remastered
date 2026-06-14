extends VBoxContainer

@export var message_scene: PackedScene
@export var message_container: VBoxContainer

func _ready():
	Multiplayer.lobby.chat.on_message.connect(_on_message)
	$InputConatiner/Button.pressed.connect(_on_pressed)
	
func _on_message(nickname: String, message: String):
	var message_comp = message_scene.instantiate()
	message_comp.get_node("Label").text = nickname + ": " + message
	message_container.add_child(message_comp)

func _on_pressed():
	var text = $InputConatiner/LineEdit.text
	Multiplayer.lobby.chat.send_message.rpc(text)
	$InputConatiner/LineEdit.text = ""
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_text_submit"):
		_on_pressed()
	
	if Input.is_action_just_pressed("ui_cancel"):
		pass
		
