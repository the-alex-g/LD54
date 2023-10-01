class_name ThreadGate
extends Construction

signal use_gate

var _is_player_in_area := false


func _process(_delta:float)->void:
	if _is_player_in_area and Input.is_action_just_pressed("use_gate"):
		use_gate.emit()


func _on_area_2d_body_entered(body)->void:
	if body is Player:
		_is_player_in_area = true


func _on_area_2d_body_exited(body)->void:
	if body is Player:
		_is_player_in_area = false
