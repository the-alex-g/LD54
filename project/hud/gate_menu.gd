class_name GateMenu
extends ColorRect

signal sphere_selected(sphere_index)
signal create_new_sphere

@export var sphere_seperation := 16

@onready var _animation_player : AnimationPlayer = $AnimationPlayer
@onready var _node_container : Control = $NodeContainer


func play_show()->void:
	_animation_player.play("show")


func play_hide()->void:
	_animation_player.play("hide")


func create_sphere_map(spheres:int, connected_spheres:Array, current_sphere:int)->void:
	for child in _node_container.get_children():
		child.queue_free()
	
	var spheres_left = spheres - 1
	var passes := 1
	while spheres_left > 0:
		spheres_left -= passes * 3
		passes += 1
	
	_add_gate_node(Vector2.ZERO, 0, connected_spheres.has(0), current_sphere == 0)
	var last_pass := {}
	var sphere_index := 1
	if passes > 1:
		for i in 3:
			if sphere_index == spheres:
				return
			var node_position := Vector2.RIGHT.rotated(TAU * i / 3.0) * sphere_seperation
			last_pass[node_position] = Vector2.ZERO
			_add_gate_node(node_position, sphere_index, connected_spheres.has(sphere_index), current_sphere == sphere_index)
			sphere_index += 1
	if passes > 2:
		for p in passes - 2:
			var this_pass := {}
			for point in last_pass:
				for i in 2:
					if sphere_index == spheres:
						return
					var node_position : Vector2 = point + Vector2.RIGHT.rotated(point.angle_to_point(last_pass[point]) + (TAU / 3 if i == 0 else -TAU / 3)) * sphere_seperation
					_add_gate_node(node_position, sphere_index, connected_spheres.has(sphere_index), current_sphere == sphere_index)
					this_pass[node_position] = point
					sphere_index += 1
			last_pass = this_pass


func _add_gate_node(at:Vector2, sphere:int, connected:bool, current_sphere:bool)->void:
	var gate_node : GateNode = load("res://hud/gate_node.tscn").instantiate()
	gate_node.position = at + size / 2.0
	_node_container.add_child(gate_node)
	gate_node.sphere_index = sphere
	gate_node.current_sphere = current_sphere
	gate_node.connected = connected
	gate_node.pressed.connect(_on_gate_node_pressed)


func _on_gate_node_pressed(sphere_index:int)->void:
	sphere_selected.emit(sphere_index)


func _on_button_pressed()->void:
	create_new_sphere.emit()
