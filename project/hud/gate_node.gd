class_name GateNode
extends Control

signal pressed(sphere_index)

var sphere_index : int
var current_sphere : bool
var connected : bool


func _on_gui_input(event:InputEvent)->void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pressed.emit(sphere_index)


func _draw()->void:
	draw_circle(Vector2.ZERO, 3, Color.GOLD)
