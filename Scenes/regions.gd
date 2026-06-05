extends Node3D

func _ready():
	var script = load("res://scripts/territory.gd")
	for child in get_children():
		child.set_script(script)
		child._ready()
