class_name MainMenu
extends Control


func _ready()->void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		$VBoxContainer/Fullscreen.button_pressed = true


func _on_fullscreen_toggled(button_pressed:bool)->void:
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_play_pressed()->void:
	get_tree().change_scene_to_file("res://world/world.tscn")
