extends Button


func _on_pressed():
	Multiplayer.lobby.host()
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")
	
func _ready():
	pressed.connect(_on_pressed)
