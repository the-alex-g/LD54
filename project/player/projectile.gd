class_name Projectile
extends Area2D

var target : Vector2
var _disabled := false


func _ready()->void:
	$CPUParticles2D.emitting = true


func _process(delta:float)->void:
	if _disabled:
		return
	global_position = lerp(global_position, target, 0.75 * delta)
	if global_position.distance_squared_to(target) < 25.0:
		_kill()


func _kill()->void:
	_disabled = true
	await get_tree().create_tween().set_trans(Tween.TRANS_QUAD).tween_property(self, "modulate", Color(Color.WHITE, 0.0), 0.25).finished
	queue_free()


func _on_area_entered(area:Area2D)->void:
	if _disabled:
		return
	
	if area is Enemy:
		area.kill()
		_kill()


func _on_body_entered(body)->void:
	if not body is Player:
		_kill()
