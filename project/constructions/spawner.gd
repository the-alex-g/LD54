class_name Spawner
extends Construction

signal spawn(path, from, spawner)

@export var path : String
@export var frequency := 10
@export var max_children := 3

var children := 0


func _ready()->void:
	var timer := Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start(frequency)


func _on_timer_timeout()->void:
	if children < max_children:
		spawn.emit(path, global_position, self)
		children += 1


func _on_child_died()->void:
	children -= 1
