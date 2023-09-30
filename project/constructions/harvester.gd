class_name Harvester
extends Construction

signal resource_collected(resource_type)

var resources_collected := 3
var target := Vector2.INF
var potential_targets : Array[Vector2] = [] : set = _set_potential_targets


func _process(delta:float)->void:
	if resources_collected == 3 and potential_targets.size() > 0:
		_find_new_target()
	if target != Vector2.INF:
		global_position = lerp(global_position, target, 0.5 * delta)
		if target.distance_squared_to(global_position) < 0.01:
			_reached_target()


func _find_new_target()->void:
	target = potential_targets.pick_random()
	resources_collected = 0


func _reached_target()->void:
	target = Vector2.INF


func collect(resource_type:String)->void:
	resource_collected.emit(resource_type)
	resources_collected += 1


func _set_potential_targets(value:Array[Vector2])->void:
	potential_targets = value
	if potential_targets.size() > 0:
		_find_new_target()


func _on_area_2d_area_entered(area:Area2D)->void:
	if area is ResourceParticle:
		collect(area.resource_type)
		area.queue_free()
