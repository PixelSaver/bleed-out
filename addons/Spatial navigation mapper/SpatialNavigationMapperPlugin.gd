@tool
extends EditorPlugin


func _enter_tree():
	# Initialization of the plugin goes here.
	add_custom_type("UI-navigation-mapper", "Control", load("res://addons/Spatial navigation mapper/NavMapper.gd"), load("res://addons/Spatial navigation mapper/NavMapperIcon.png"))
	pass


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_custom_type("UI-navigation-mapper")
	pass
