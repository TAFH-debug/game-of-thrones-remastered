extends Control

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		visible = !visible
