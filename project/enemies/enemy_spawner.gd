class_name EnemySpawner
extends Node2D

signal spawn_enemy(from)

var _total_constructions := 0
var _spawn_rate := 0.0

@onready var _spawn_timer : Timer = $Timer


func _update_spawn_rate()->void:
	if _total_constructions > 3:
		_spawn_rate = clamp(lerp(10, 1, (_total_constructions - 3) / 10.0), 1.0, 10.0)
		if _spawn_timer.is_stopped():
			_spawn_timer.start(_spawn_rate)
	elif not _spawn_timer.is_stopped():
		_spawn_timer.stop()
	print(_spawn_rate)


func _on_timer_timeout():
	spawn_enemy.emit(global_position)
	_spawn_timer.start(_spawn_rate)


func _on_world_construction_built()->void:
	_total_constructions += 1
	_update_spawn_rate()


func _on_world_construction_destroyed()->void:
	_total_constructions -= 1
	_update_spawn_rate()
