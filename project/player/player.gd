class_name Player
extends CharacterBody2D

signal build
signal resource_collected(resource_type)

@export var speed := 150.0
@export var squish := 1
@export var cooldown_time := 1.0
@export var projectile_range := 64.0

var x_direction := 1 : set = _set_x_direction
var paused := false : set = _set_paused
var _can_attack := true

@onready var _sprite := $Nautilus


func _physics_process(delta:float)->void:
	if paused:
		return
	
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
	
	if Input.is_action_just_pressed("attack") and _can_attack:
		_attack()


func _attack()->void:
	var projectile := preload("res://player/projectile.tscn").instantiate()
	projectile.position = global_position
	get_parent().add_child(projectile)
	projectile.target = global_position + Vector2(projectile_range, 0) * sign(_sprite.scale.x)
	
	_can_attack = false
	await get_tree().create_timer(cooldown_time).timeout
	_can_attack = true


func _build()->void:
	_set_paused(true)
	build.emit()


func _set_paused(value:bool)->void:
	velocity = Vector2.ZERO
	paused = value


func _set_x_direction(value:int)->void:
	if x_direction != value:
		x_direction = value
		get_tree().create_tween().set_trans(Tween.TRANS_QUAD).tween_property(_sprite, "scale", Vector2(x_direction, 1), 0.5)


func collect(resource:String)->void:
	resource_collected.emit(resource)
