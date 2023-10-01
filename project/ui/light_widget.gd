class_name LightWidget
extends Node2D

@export var min_lights := 5
@export var max_lights := 15
@export var min_distance := 10
@export var max_distance := 150
@export var min_speed := 0.1
@export var max_speed := 1.0
@export var color := Color.WHITE : set = _set_color

var _speeds := []


func _ready()->void:
	for _i in round(lerp(min_lights, max_lights, randf())):
		_add_light()
		_speeds.append(lerp(min_speed, max_speed, randf()))


func _process(delta:float)->void:
	for i in get_child_count():
		var light = get_child(i)
		light.rotation += _speeds[i] * delta


func _add_light()->void:
	var hinge := Node2D.new()
	hinge.rotation = TAU * randf()
	add_child(hinge)
	var light := Sprite2D.new()
	light.texture = load("res://hud/light.png")
	light.position.x = lerp(min_distance, max_distance, randf())
	hinge.call_deferred("add_child", light)


func _set_color(value:Color)->void:
	color = value
	modulate = color

