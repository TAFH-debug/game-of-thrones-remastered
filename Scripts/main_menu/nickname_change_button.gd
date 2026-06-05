extends Button

@export var nickname_input: TextEdit

func _on_pressed():
	PlayerSettings.nickname = nickname_input.text
	
func _ready():
	pressed.connect(_on_pressed)
