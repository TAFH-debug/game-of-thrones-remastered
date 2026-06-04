extends Panel

func _ready():
	var style = StyleBoxFlat.new()
	style.bg_color = Color("2a1a0e")        # тёмно-коричневый
	style.border_color = Color("8b6914")    # золотисто-жёлтый
	style.set_border_width_all(3)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	add_theme_stylebox_override("panel", style)
