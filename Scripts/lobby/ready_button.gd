extends TextureButton

var is_ready = false

func _on_pressed():
	is_ready = !is_ready
	Multiplayer.lobby.set_ready.rpc(is_ready)
	
func _ready():
	pressed.connect(_on_pressed)
