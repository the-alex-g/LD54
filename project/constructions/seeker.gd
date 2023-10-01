class_name Seeker
extends Construction

var target : Enemy
var potential_targets := []

@onready var _sprite : AnimatedSprite2D = $AnimatedSprite2D


func _process(delta:float)->void:
	if is_instance_valid(target):
		if global_position.distance_squared_to(target.global_position) > 5.0:
			global_position = lerp(global_position, target.global_position, 0.9 * delta)
		if target.global_position.x < global_position.x:
			_sprite.flip_h = true
		else:
			_sprite.flip_h = false
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


func _on_area_2d_area_entered(area:Area2D)->void:
	if area is Enemy:
		area.kill()
		kill()
