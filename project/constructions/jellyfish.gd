class_name Jellyfish
extends Construction

var _top_limit : float
var _bottom_limit : float
var _y_direction : int = sign(randf() - 0.5)


func _ready()->void:
	var intersection := get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2.UP * 400, 0b10))
	_top_limit = Vector2(intersection.position.x, intersection.position.y + 8).y
	intersection = get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2.DOWN * 400, 0b10))
	_bottom_limit = Vector2(intersection.position.x, intersection.position.y - 8).y


func _process(delta:float)->void:
	if _y_direction < 0:
		global_position.y = lerp(global_position.y, _top_limit, 0.5 * delta)
	else:
		global_position.y = lerp(global_position.y, _bottom_limit, 0.5 * delta)
	
	if abs(global_position.y - _top_limit) < 1.0 or abs(global_position.y - _bottom_limit) < 1.0:
		_y_direction *= -1


func _on_area_2d_area_entered(area:Area2D)->void:
	if area is Enemy:
		area.kill()
		if area.global_position.y < global_position.y:
			kill()
