class_name HUD
extends CanvasLayer

signal build(info, location, anchors)
signal clear(location)
signal new_sphere
signal sphere_changed(new_sphere)

const CONSTRUCTIONS := [
	{"name":"Glowing Algae", "anchors":[Construction.ANCHOR_ALL], "anchors_exclude":[], "cost":{"chitin":2, "threads":2}, "path":"res://constructions/glowing_algae.tscn"},
	{"name":"Detritivores", "anchors":[Construction.ANCHOR_BOTTOM], "anchors_exclude":[], "cost":{"light":2, "threads":2}, "path":"res://constructions/detritivores.tscn"},
	{"name":"Mussel Bed", "anchors":[Construction.ANCHOR_BOTTOM, Construction.ANCHOR_SIDE], "anchors_exclude":[], "cost":{"light":2, "chitin":2}, "path":"res://constructions/mussel_bed.tscn"},
	{"name":"Coral Bed", "anchors":[Construction.ANCHOR_BOTTOM, Construction.ANCHOR_SIDE], "anchors_exclude":[], "cost":{"light":5, "chitin":5, "threads":5}, "path":"res://constructions/coral_bed.tscn"},
	{"name":"Harvester", "anchors":[Construction.ANCHOR_NONE], "anchors_exclude":[Construction.ANCHOR_ALL], "cost":{"light":2, "chitin":2, "threads":2}, "path":"res://constructions/harvester.tscn"},
	{"name":"Jellyfish", "anchors":[Construction.ANCHOR_NONE], "anchors_exclude":[Construction.ANCHOR_ALL], "cost":{"light":3, "chitin":1, "threads":2}, "path":"res://constructions/jellyfish.tscn"},
	{"name":"Seeker", "anchors":[Construction.ANCHOR_NONE], "anchors_exclude":[Construction.ANCHOR_ALL], "cost":{"light":3, "chitin":2, "threads":2}, "path":"res://constructions/seeker.tscn"},
	{"name":"Harvester Spawn", "anchors":[Construction.ANCHOR_BOTTOM], "anchors_exclude":[], "cost":{"light":2, "chitin":8, "threads":8}, "path":"res://constructions/harvester_spawn.tscn"},
	{"name":"Seeker Spawn", "anchors":[Construction.ANCHOR_BOTTOM], "anchors_exclude":[], "cost":{"light":4, "chitin":10, "threads":8}, "path":"res://constructions/seeker_spawn.tscn"},
	{"name":"Jellyfish Spawn", "anchors":[Construction.ANCHOR_BOTTOM, Construction.ANCHOR_TOP], "anchors_exclude":[], "cost":{"light":8, "chitin":4, "threads":8}, "path":"res://constructions/jellyfish_spawn.tscn"},
	{"name":"Thread Gate", "anchors":[Construction.ANCHOR_BOTTOM], "anchors_exclude":[Construction.ANCHOR_TOP], "cost":{}, "path":"res://constructions/thread_gate.tscn"},
	{"name":"Abyssal Thread", "anchors":[Construction.ANCHOR_ALL], "anchors_exclude":[], "cost":{}, "path":"res://constructions/abyssal_thread.tscn"},
]

var _build_location := Vector2i.ZERO
var _anchors := []
var _resources := [{"light":4, "chitin":4, "threads":4,}]
var _available_resources := {"light":4, "chitin":4, "threads":4}
var _can_build := true
var _current_sphere_index := -1
var _connected_spheres := []
var _spheres_with_threads := []

@onready var _build_list : ItemList = $Control/BuildList
@onready var _chitin_label : Label = $HBoxContainer/Tick/TickLabel
@onready var _thread_label : Label = $HBoxContainer/Threads/ThreadLabel
@onready var _light_label : Label = $HBoxContainer/Light/LightLabel
@onready var _gate_menu : GateMenu = $GateMenu


func _ready()->void:
	_update_resource_labels()


func _on_world_update_anchors(anchors:Array, location:Vector2i)->void:
	_can_build = true
	_build_list.clear()
	_anchors = anchors
	_build_location = location
	
	for construction in CONSTRUCTIONS:
		var can_build_construction := false
		
		if _can_afford_construction(construction.cost):
			for anchor in construction.anchors_exclude:
				match anchor:
					Construction.ANCHOR_ALL:
						if anchors.size() > 0:
							break
					Construction.ANCHOR_SIDE:
						if anchors.has(Construction.ANCHOR_LEFT) or anchors.has(Construction.ANCHOR_RIGHT):
							break
					_:
						if anchors.has(anchor):
							break
			for anchor in construction.anchors:
				match anchor:
					Construction.ANCHOR_ALL:
						if anchors.size() > 0:
							can_build_construction = true
							break
					Construction.ANCHOR_NONE:
						if anchors.size() == 0:
							can_build_construction = true
							break
					Construction.ANCHOR_SIDE:
						if anchors.has(Construction.ANCHOR_LEFT) or anchors.has(Construction.ANCHOR_RIGHT):
							can_build_construction = true
							break
					_:
						if anchors.has(anchor):
							can_build_construction = true
							break
		
		if construction.name == "Thread Gate" and _connected_spheres.has(_current_sphere_index):
			can_build_construction = false
		elif construction.name == "Abyssal Thread" and _spheres_with_threads.has(_current_sphere_index):
			can_build_construction = false
		
		if can_build_construction:
			_add_building_to_list(construction)


func _can_afford_construction(cost:Dictionary)->bool:
	var can_afford_construction := true
	
	for resource in cost:
		if _available_resources[resource] < cost[resource]:
			can_afford_construction = false
			break
	
	return can_afford_construction


func _add_building_to_list(building:Dictionary)->void:
	_build_list.add_item(building.name)


func _get_construction_by_name(construction_name:String)->Dictionary:
	for construction in CONSTRUCTIONS:
		if construction.name == construction_name:
			return construction
	
	return {}


func _spend_resources(cost:Dictionary)->void:
	for resource in cost:
		if not _connected_spheres.has(_current_sphere_index):
			_resources[_current_sphere_index][resource] -= cost[resource]
		else:
			var cost_left : int = cost[resource]
			var index := 0
			while cost_left > 0:
				var sphere_index : int = _connected_spheres[index % _connected_spheres.size()]
				_resources[sphere_index][resource] -= 1
				cost_left -= 1
				index += 1
	
	_update_available_resources()
	_update_resource_labels()


func _update_resource_labels()->void:
	_chitin_label.text = str(_available_resources.chitin)
	_thread_label.text = str(_available_resources.threads)
	_light_label.text = str(_available_resources.light)


func _get_shared_anchors(x:Array, y:Array)->Array:
	var shared_anchors : Array = []
	for anchor in x:
		match anchor:
			Construction.ANCHOR_ALL:
				shared_anchors = y
				return shared_anchors
			Construction.ANCHOR_NONE:
				return []
			Construction.ANCHOR_SIDE:
				if y.has(Construction.ANCHOR_LEFT):
					shared_anchors.append(Construction.ANCHOR_LEFT)
				if y.has(Construction.ANCHOR_RIGHT):
					shared_anchors.append(Construction.ANCHOR_RIGHT)
			_:
				if y.has(anchor):
					shared_anchors.append(anchor)
	return shared_anchors


func _update_available_resources()->void:
	_available_resources = {"chitin":0, "light":0, "threads":0}
	for i in _resources.size():
		if (_connected_spheres.has(i) and _connected_spheres.has(_current_sphere_index)) or i == _current_sphere_index:
			_available_resources.chitin += _resources[i].chitin
			_available_resources.threads += _resources[i].threads
			_available_resources.light += _resources[i].light


func _on_world_update_resources(resource:String, sphere_index:int)->void:
	_resources[sphere_index][resource] += 1
	if sphere_index == _current_sphere_index:
		_update_available_resources()
	elif _connected_spheres.has(sphere_index) and _connected_spheres.has(_current_sphere_index):
		_update_available_resources()
	_update_resource_labels()


func _on_world_build_invalid(location:Vector2i)->void:
	_build_list.clear()
	_build_location = location
	_build_list.add_item("Clear Space")
	_can_build = false


func _on_build_list_item_selected(index:int)->void:
	var selected_name := _build_list.get_item_text(index)
	if selected_name == "Clear Space":
		clear.emit(_build_location)
	else:
		var selected_info := _get_construction_by_name(selected_name)
		_spend_resources(selected_info.cost)
		build.emit(selected_info.path, _build_location, _get_shared_anchors(selected_info.anchors, _anchors))
	_build_list.deselect_all()
	_build_list.release_focus()


func _on_world_changed_spheres(new_sphere_index:int)->void:
	if not _connected_spheres.has(new_sphere_index) and _current_sphere_index != -1:
		_resources[new_sphere_index] = _available_resources
		_spend_resources(_available_resources)
	
	_current_sphere_index = new_sphere_index
	
	_update_available_resources()
	_update_resource_labels()


func _on_world_update_connected_spheres(connected_spheres:Array)->void:
	_connected_spheres = connected_spheres
	_update_available_resources()
	_update_resource_labels()


func _on_world_open_gate_menu(number_of_spheres:int)->void:
	_gate_menu.create_sphere_map(number_of_spheres, _connected_spheres, _current_sphere_index)
	_gate_menu.play_show()


func _on_gate_menu_create_new_sphere()->void:
	_resources.append({"chitin":0, "light":0, "threads":0})
	new_sphere.emit()
	_gate_menu.play_hide()


func _on_gate_menu_sphere_selected(sphere_index:int)->void:
	sphere_changed.emit(sphere_index)
	_gate_menu.play_hide()


func _on_world_game_won()->void:
	print("you won! Good jairb!")


func _on_world_update_abyssal_threads(spheres_with_threads:Array)->void:
	_spheres_with_threads = spheres_with_threads
