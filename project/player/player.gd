class_name Player
extends CharacterBody2D

signal build()

@export var speed := 150.0
@export var squish := 1

var x_direction := 1 : set = _set_x_direction

@onready var _sprite := $Nautilus


func _physics_process(delta:float)->void:
	_process_actions(delta)
	
	move_and_slide()


func _process_actions(delta:float)->void:
	var movement := Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	)
	
	if movement.x != 0:
		_set_x_direction(sign(movement.x))
	
	velocity = lerp(velocity, movement * speed, squish * delta)
	
	if Input.is_action_just_pressed("build"):
		_build()


func _build()->void:
	build.emit()


func _set_x_direction(value:int)->void:
	if x_direction != value:
		x_direction = value
		get_tree().create_tween().set_trans(Tween.TRANS_QUAD).tween_property(_sprite, "scale", Vector2(x_direction, 1), 0.5)
