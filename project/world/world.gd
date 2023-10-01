extends Node2D

signal update_anchors(anchors, location)
signal update_resources(new_resources, sphere_index)
signal build_invalid(location)
signal construction_built(sphere_index)
signal construction_destroyed(sphere_index)
signal changed_spheres(new_sphere_index, sphere_connected)
signal update_connected_spheres(connected_spheres)
signal open_gate_menu(spheres)
signal update_abyssal_threads(spheres_with_threads)
signal game_won

@export var min_sphere_radius := 4
@export var max_sphere_radius := 8
@export var sphere_seperation := 400

var _points_occupied := []
var _harvesters := []
var _enemies : = []
var _jellyfish := []
var _seekers := []
var _spheres := 0
var _current_sphere_index := -1
var _connected_spheres := []
var _enemy_spawners := {}
var _abyssal_threads := []

@onready var _tilemap : TileMap = $TileMap
@onready var _player : Player = $Player
@onready var _camera : Camera2D = $Camera2D
@onready var _construction_container : Node2D = $ConstructionContainer


func _ready()->void:
	_generate_sphere(Vector2i.ZERO, round(lerp(min_sphere_radius, max_sphere_radius, randf())))
	_update_build_anchors(_player.global_position)


func _generate_sphere(at:Vector2i, radius:int)->void:
	_spheres += 1
	_points_occupied.append({})
	_harvesters.append([])
	_jellyfish.append([])
	_seekers.append([])
	_enemies.append([])
	_change_sphere(_spheres - 1)
	for x in range(-radius - 10, radius + 1 + 10):
		for y in range(-radius - 10, radius + 1 + 10):
			if pow(x, 2) + pow(y, 2) >= pow(radius, 2):
				_tilemap.set_cell(0, Vector2i(x, y) + at, 0, Vector2i.ZERO)
	
	var enemy_spawner : EnemySpawner = load("res://enemies/enemy_spawner.tscn").instantiate()
	enemy_spawner.sphere_index = _current_sphere_index
	construction_destroyed.connect(Callable(enemy_spawner, "_on_world_construction_destroyed"))
	construction_built.connect(Callable(enemy_spawner, "_on_world_construction_built"))
	enemy_spawner.global_position = _tilemap.map_to_local(at)
	enemy_spawner.spawn_enemy.connect(_on_enemy_spawner_spawn_enemy)
	_enemy_spawners[_current_sphere_index] = enemy_spawner
	_construction_container.add_child(enemy_spawner)


func _change_sphere(to:int)->void:
	_current_sphere_index = to
	changed_spheres.emit(_current_sphere_index)
	_camera.position = Vector2.RIGHT * _current_sphere_index * sphere_seperation
	_player.position = _camera.position
	_player.velocity = Vector2.ZERO
	$Background.position = _player.position - Vector2(200, 160)


func _update_build_anchors(at:Vector2)->void:
	var map_coords := _tilemap.local_to_map(at)
	
	var valid_build_anchors := []
	
	if _points_occupied[_current_sphere_index].has(map_coords):
		build_invalid.emit(map_coords)
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


func _build_construction(path:String, location:Vector2i, anchors:Array, sphere_index:int)->Construction:
	var construction : Construction = load(path).instantiate()
	construction.global_position = _tilemap.map_to_local(location)
	if anchors.size() > 0:
		_points_occupied[sphere_index][location] = construction
	_construction_container.add_child(construction)
	construction.call_deferred("set_anchors", anchors)
	construction.sphere_index = sphere_index
	
	construction.died.connect(_on_construction_died.bind(construction))
	
	if construction is Harvester:
		construction.resource_collected.connect(_on_resource_collected)
		_harvesters[sphere_index].append(construction)
		_update_harvester_targets()
	elif construction is Spawner:
		construction.spawn.connect(_on_spawner_spawn)
	elif construction is Jellyfish:
		_jellyfish[sphere_index].append(construction)
	elif construction is Generator:
		_update_harvester_targets()
	elif construction is Seeker:
		_seekers[sphere_index].append(construction)
		_update_seeker_targets()
	elif construction is ThreadGate:
		_connected_spheres.append(_current_sphere_index)
		update_connected_spheres.emit(_connected_spheres)
		construction.use_gate.connect(_on_thread_gate_use_gate)
	elif construction is AbyssalThread:
		_build_abyssal_thread(_current_sphere_index)
	
	_update_enemy_targets()
	
	construction_built.emit(sphere_index)
	
	return construction


func _build_abyssal_thread(sphere_index:int)->void:
	_enemy_spawners[sphere_index].queue_free()
	_abyssal_threads.append(sphere_index)
	update_abyssal_threads.emit(_abyssal_threads)
	if _abyssal_threads.size() == 6:
		game_won.emit()


func _update_harvester_targets()->void:
	for group in _harvesters:
		var generator_locations := _get_generator_locations(_harvesters.find(group))
		for harvester in group:
			harvester.potential_targets = generator_locations


func _get_generator_locations(sphere_index)->Array[Vector2]:
	var generator_locations : Array[Vector2] = []
	for location in _points_occupied[sphere_index]:
		if is_instance_valid(_points_occupied[sphere_index][location]):
			if _points_occupied[sphere_index][location] is Generator:
				generator_locations.append(_tilemap.map_to_local(location))
	return generator_locations


func _spawn_enemy(at:Vector2, sphere_index:int)->void:
	var enemy : Enemy = load("res://enemies/enemy.tscn").instantiate()
	enemy.global_position = at
	enemy.sphere_index = sphere_index
	_construction_container.add_child(enemy)
	_enemies[sphere_index].append(enemy)
	enemy.died.connect(_on_enemy_died.bind(enemy))
	
	_update_enemy_targets()
	_update_seeker_targets()


func _update_enemy_targets()->void:
	for group in _enemies:
		var local_sphere_index = _enemies.find(group)
		var potential_targets := []
		potential_targets.append_array(_points_occupied[local_sphere_index].values())
		potential_targets.append_array(_harvesters[local_sphere_index])
		potential_targets.append_array(_jellyfish[local_sphere_index])
		potential_targets.append_array(_seekers[local_sphere_index])
		for enemy in group:
			enemy.potential_targets = potential_targets


func _update_seeker_targets()->void:
	for group in _seekers:
		for seeker in group:
			seeker.potential_targets = _enemies[seeker.sphere_index]


func _on_enemy_died(enemy:Enemy)->void:
	_enemies[enemy.sphere_index].erase(enemy)
	_update_seeker_targets()


func _on_hud_build(path:String, location:Vector2i, anchors:Array)->void:
	_build_construction(path, location, anchors, _current_sphere_index)


func _on_resource_collected(resource_type:String)->void:
	update_resources.emit(resource_type, _current_sphere_index)


func _on_construction_died(construction:Construction)->void:
	_points_occupied[construction.sphere_index].erase(_tilemap.local_to_map(construction.global_position))
	if construction is Generator:
		_update_harvester_targets()
	elif construction is Jellyfish:
		_jellyfish[construction.sphere_index].erase(construction)
	elif construction is Harvester:
		_harvesters[construction.sphere_index].erase(construction)
	elif construction is Seeker:
		_seekers[construction.sphere_index].erase(construction)
	elif construction is ThreadGate:
		_connected_spheres.erase(construction.sphere_index)
		update_connected_spheres.emit(_connected_spheres)
	
	construction_destroyed.emit(construction.sphere_index)
	_update_enemy_targets()


func _on_spawner_spawn(path:String, from:Vector2, spawner:Spawner)->void:
	_build_construction(path, _tilemap.local_to_map(from), [Construction.ANCHOR_NONE], spawner.sphere_index).died.connect(Callable(spawner, "_on_child_died"))


func _on_enemy_spawner_spawn_enemy(from:Vector2, sphere_index:int)->void:
	_spawn_enemy(from, sphere_index)


func _on_hud_clear(location:Vector2i)->void:
	_points_occupied[_current_sphere_index][location].kill()


func _on_thread_gate_use_gate()->void:
	open_gate_menu.emit(_spheres)


func _on_hud_new_sphere()->void:
	_generate_sphere(_tilemap.local_to_map(Vector2i.RIGHT * _spheres * sphere_seperation), round(lerp(min_sphere_radius, max_sphere_radius, randf())))


func _on_hud_sphere_changed(new_sphere:int)->void:
	_change_sphere(new_sphere)
