class_name HUD
extends CanvasLayer

signal build(info, location, anchors)
signal build_abort

const CONSTRUCTIONS := [
	{"name":"Top", "anchors":[Construction.ANCHOR_TOP], "anchors_exclude":[], "cost":{}},
	{"name":"Bottom", "anchors":[Construction.ANCHOR_BOTTOM], "anchors_exclude":[], "cost":{"light":1}},
	{"name":"Side", "anchors":[Construction.ANCHOR_SIDE], "anchors_exclude":[], "cost":{}},
	{"name":"Glowing Algae", "anchors":[Construction.ANCHOR_ALL], "anchors_exclude":[], "cost":{}, "path":"res://constructions/glowing_algae.tscn"},
	{"name":"Harvester", "anchors":[Construction.ANCHOR_NONE], "anchors_exclude":[Construction.ANCHOR_ALL], "cost":{}, "path":"res://constructions/harvester.tscn"},
]

var _build_location := Vector2i.ZERO
var _build_menu_open := false : set = _set_build_menu_open
var _anchors := []
var _resources := {"light":0, "chitin":0, "threads":0,}
var _can_build := true

@onready var _build_list : ItemList = $Control/BuildList
@onready var _build_menu : ItemList = $Control/BuildMenu


func _input(event:InputEvent)->void:
	if _build_menu_open:
		if event is InputEventKey:
			if event.pressed and event.keycode == KEY_ESCAPE:
				build_abort.emit()
				_set_build_menu_open(false)


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
		
		if can_build_construction:
			_add_building_to_list(construction)


func _can_afford_construction(cost:Dictionary)->bool:
	var can_afford_construction := true
	
	for resource in cost:
		if _resources[resource] < cost[resource]:
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
		_resources[resource] -= cost[resource]


func _set_build_menu_open(value:bool)->void:
	_build_menu_open = value
	_build_menu.visible = _build_menu_open


func _on_world_open_build_menu()->void:
	if _can_build and _build_list.item_count > 0:
		_build_menu.clear()
	
		for i in _build_list.item_count:
			_build_menu.add_item(_build_list.get_item_text(i))
		_set_build_menu_open(true)
	else:
		build_abort.emit()


func _on_world_update_resources(resource:String)->void:
	_resources[resource] += 1


func _on_build_menu_item_selected(index:int)->void:
	var selected_name := _build_menu.get_item_text(index)
	var selected_info := _get_construction_by_name(selected_name)
	_spend_resources(selected_info.cost)
	build.emit(selected_info.path, _build_location, _anchors)
	_set_build_menu_open(false)


func _on_world_build_invalid()->void:
	_build_list.clear()
	_can_build = false
