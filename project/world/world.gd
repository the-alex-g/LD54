extends Node2D

signal update_anchors(anchors, location)
signal open_build_menu

enum Anchors {TOP, BOTTOM, SIDE}

@export var min_bubble_radius := 8
@export var max_bubble_radius := 16

@onready var _tilemap : TileMap = $TileMap
@onready var _player : Player = $Player


func _ready()->void:
	_generate_bubble(Vector2i.ZERO, 8)
	_update_build_anchors(_player.global_position)


func _generate_bubble(at:Vector2i, radius:int)->void:
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			if pow(x, 2) + pow(y, 2) < pow(radius + 1, 2) and pow(x, 2) + pow(y, 2) >= pow(radius, 2):
				_tilemap.set_cell(0, Vector2i(x, y) + at, 0, Vector2i.ZERO)


func _update_build_anchors(at:Vector2)->void:
	var map_coords := _tilemap.local_to_map(at)
	
	var valid_build_anchors := []
	
	if _tilemap.get_cell_source_id(0, map_coords + Vector2i.DOWN) > -1:
		valid_build_anchors.append(Anchors.BOTTOM)
	if _tilemap.get_cell_source_id(0, map_coords + Vector2i.UP) > -1:
		valid_build_anchors.append(Anchors.TOP)
	if _tilemap.get_cell_source_id(0, map_coords + Vector2i.LEFT) > -1:
		valid_build_anchors.append(Anchors.SIDE)
	elif _tilemap.get_cell_source_id(0, map_coords + Vector2i.RIGHT) > -1:
		valid_build_anchors.append(Anchors.SIDE)
	
	update_anchors.emit(valid_build_anchors, map_coords)
	
	# run this function every .1 seconds
	await get_tree().create_timer(0.1).timeout
	_update_build_anchors(_player.global_position)
