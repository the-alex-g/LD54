class_name Enemy
extends Area2D

signal died

@export var cooldown := 5.0

var target : Construction = null
var potential_targets := []
var _can_damage := true

@onready var _cooldown_timer : Timer = $CooldownTimer


func _process(delta:float)->void:
	if is_instance_valid(target):
		if target.global_position.distance_squared_to(global_position) > 1.0:
			global_position = lerp(global_position, target.global_position, 0.4 * delta)
		if Geometry2D.is_point_in_circle(target.global_position, global_position, 10) and _can_damage:
			_damage_target()
		
	else:
		_find_new_target()


func _find_new_target()->void:
	_clean_potential_targets()
	if potential_targets.size() > 0:
		target = potential_targets.pick_random()


func _clean_potential_targets()->void:
	for t in potential_targets:
		if not is_instance_valid(t):
			potential_targets.erase(t)


func _damage_target()->void:
	target.kill()
	_can_damage = false
	_cooldown_timer.start()


func kill()->void:
	died.emit()
	queue_free()


func _on_cooldown_timer_timeout()->void:
	_can_damage = true
