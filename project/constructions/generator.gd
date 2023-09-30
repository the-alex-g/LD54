class_name Generator
extends Construction

@export var frequency := 1.0
@export var resources := {
	"light":0,
	"chitin":0,
	"threads":0,
}


func _ready()->void:
	var timer := Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start(frequency)


func _on_timer_timeout()->void:
	for resource in resources:
		for i in resources[resource]:
			_generate_resource_particle(resource)


func _generate_resource_particle(resource_type:String)->void:
	var particle : ResourceParticle = preload("res://resources/resource_particle.tscn").instantiate()
	particle.global_position = global_position
	particle.resource_type = resource_type
	get_parent().add_child(particle)
	particle.set_deferred("emitted_from", anchor)
