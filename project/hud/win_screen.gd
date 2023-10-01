class_name WinScreen
extends Control

@onready var _animation_player : AnimationPlayer = $AnimationPlayer


func _ready()->void:
	hide()


func fade_in()->void:
	_animation_player.play("fade_in")


func _on_play_again_pressed()->void:
	get_tree().change_scene_to_file("res://world/world.tscn")


func _on_main_menu_pressed()->void:
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
