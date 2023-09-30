class_name EnemySpawner
extends Node2D

signal spawn_enemy(from, sphere_index)

@export var spawn_time_variation := 2.0

var _total_constructions := 0
var _spawn_rate := 0.0
var sphere_index := -1

@onready var _spawn_timer : Timer = $Timer


func _update_spawn_rate()->void:
	if _total_constructions > 3:
		_spawn_rate = clamp(lerp(10, 1, (_total_constructions - 3) / 10.0), 1.0, 10.0)
		if _spawn_timer.is_stopped():
			_spawn_timer.start(_spawn_rate + randf() * spawn_time_variation)
	elif not _spawn_timer.is_stopped():
		_spawn_timer.stop()


func _on_timer_timeout():
	spawn_enemy.emit(global_position + Vector2.RIGHT.rotated(TAU * randf()) * randf() * 64, sphere_index)
	_spawn_timer.start(_spawn_rate)


func _on_world_construction_built(construction_sphere_index:int)->void:
	if construction_sphere_index == sphere_index:
		_total_constructions += 1
		_update_spawn_rate()


func _on_world_construction_destroyed(construction_sphere_index:int)->void:
	if construction_sphere_index == sphere_index:
		_total_constructions -= 1
		_update_spawn_rate()
