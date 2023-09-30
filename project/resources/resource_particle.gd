class_name ResourceParticle
extends Area2D

@export_enum("light", "chitin", "threads") var resource_type
@export var lifetime := 5.0

var emitted_from : int
var _impulse := 8.0 + randf() * 8.0
var _tilt = TAU / 12 * randf() - PI / 12


func _ready()->void:
	$Timer.start(lifetime)


func _process(delta:float)->void:
	if _impulse > 0.0:
		match emitted_from:
			Construction.ANCHOR_BOTTOM:
				position += Vector2(0, -_impulse * delta).rotated(_tilt)
			Construction.ANCHOR_TOP:
				position += Vector2(0, _impulse * delta).rotated(_tilt)
			Construction.ANCHOR_LEFT:
				position += Vector2(_impulse * delta, 0).rotated(_tilt)
			Construction.ANCHOR_RIGHT:
				position += Vector2(-_impulse * delta, 0).rotated(_tilt)
		_impulse = lerp(_impulse, 0.0, 0.5 * delta)


func _on_body_entered(body:PhysicsBody2D)->void:
	if body.has_method("collect"):
		body.collect(resource_type)
	queue_free()


func _on_timer_timeout():
	queue_free()
