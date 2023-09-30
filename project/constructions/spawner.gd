class_name Spawner
extends Construction

signal spawn(path, from, spawner)

@export var path : String
@export var frequency := 1

var children := 0


func _ready()->void:
	print("spawn ", position, " ", global_position)
	var timer := Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start(frequency)


func _on_timer_timeout()->void:
	if children < 3:
		spawn.emit(path, global_position, self)
		children += 1


func _on_child_died()->void:
	children -= 1


func _draw():
	draw_circle(Vector2.ZERO, 8, Color.ORANGE)
