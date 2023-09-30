extends Node2D

signal update_anchors(anchors, location)
signal open_build_menu
signal update_resources(new_resources)
signal build_invalid

@export var min_bubble_radius := 8
@export var max_bubble_radius := 16

@onready var _tilemap : TileMap = $TileMap
@onready var _player : Player = $Player

var _points_occupied : Dictionary = {}
var _harvesters : Array[Harvester] = []


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
	
	if _points_occupied.has(map_coords):
		build_invalid.emit()
	else:
		if _tilemap.get_cell_source_id(0, map_coords + Vector2i.DOWN) > -1:
			valid_build_anchors.append(Construction.ANCHOR_BOTTOM)
		if _tilemap.get_cell_source_id(0, map_coords + Vector2i.UP) > -1:
			valid_build_anchors.append(Construction.ANCHOR_TOP)
		if _tilemap.get_cell_source_id(0, map_coords + Vector2i.LEFT) > -1:
			valid_build_anchors.append(Construction.ANCHOR_LEFT)
		elif _tilemap.get_cell_source_id(0, map_coords + Vector2i.RIGHT) > -1:
			valid_build_anchors.append(Construction.ANCHOR_RIGHT)
	
		update_anchors.emit(valid_build_anchors, map_coords)
	
	# run this function every .1 seconds
	await get_tree().create_timer(0.1).timeout
	_update_build_anchors(_player.global_position)


func _build_construction(path:String, location:Vector2i, anchors:Array)->void:
	var construction : Construction = load(path).instantiate()
	construction.global_position = _tilemap.map_to_local(location)
	if anchors.size() > 0:
		_points_occupied[location] = construction
	add_child(construction)
	construction.call_deferred("set_anchors", anchors)
	
	if construction is Harvester:
		construction.resource_collected.connect(_on_resource_collected)
		_harvesters.append(construction)
	
	for harvester in _harvesters:
		harvester.potential_targets = _get_generator_locations()


func _get_generator_locations()->Array[Vector2]:
	var generator_locations : Array[Vector2] = []
	for location in _points_occupied:
		if _points_occupied[location] is Generator:
			generator_locations.append(_tilemap.map_to_local(location))
	return generator_locations


func _on_player_build()->void:
	open_build_menu.emit()


func _on_hud_build(path:String, location:Vector2i, anchors:Array)->void:
	_build_construction(path, location, anchors)
	_player.paused = false


func _on_hud_build_abort()->void:
	_player.paused = false


func _on_resource_collected(resource_type:String)->void:
	update_resources.emit(resource_type)
