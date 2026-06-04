extends Button

@export var input: TextEdit

func _on_pressed():
	Multiplayer.lobby.join(input.text, PlayerSettings.nickname)
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")
	
func _ready():
	pressed.connect(_on_pressed)
