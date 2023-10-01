class_name GateNode
extends TextureRect

signal pressed(sphere_index)

var sphere_index : int = -1
var current_sphere : bool = false
var connected : bool = false

@onready var _animation_player : AnimationPlayer = $AnimationPlayer


func _ready()->void:
	_animation_player.play("default")
#	if current_sphere:
#		_animation_player.play("current")
#	elif not connected:
#		_animation_player.play("disconnected")


func _on_gui_input(event:InputEvent)->void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pressed.emit(sphere_index)
