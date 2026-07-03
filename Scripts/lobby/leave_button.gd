extends TextureButton

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	Multiplayer.reset()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
