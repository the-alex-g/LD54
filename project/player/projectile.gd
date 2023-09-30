class_name Projectile
extends Area2D

var target : Vector2


func _process(delta:float)->void:
	global_position = lerp(global_position, target, 0.75 * delta)
	if global_position.distance_squared_to(target) < 1.0:
		queue_free()


func _on_area_entered(area:Area2D)->void:
	if area is Enemy:
		area.kill()
		queue_free()
