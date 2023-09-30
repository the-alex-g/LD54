class_name HUD
extends CanvasLayer

signal build(info, location, anchors)
signal build_abort

const CONSTRUCTIONS := [
	{"name":"Top", "anchors":[Construction.ANCHOR_TOP], "anchors_exclude":[]},
	{"name":"Bottom", "anchors":[Construction.ANCHOR_BOTTOM], "anchors_exclude":[]},
	{"name":"Side", "anchors":[Construction.ANCHOR_SIDE], "anchors_exclude":[]},
	{"name":"Glowing Algae", "anchors":[Construction.ANCHOR_ALL], "anchors_exclude":[], "path":"res://constructions/glowing_algae.tscn"}
]

var _build_location := Vector2i.ZERO
var _build_menu_open := false : set = _set_build_menu_open
var _anchors := []

@onready var _build_list : ItemList = $Control/BuildList
@onready var _build_menu : ItemList = $Control/BuildMenu


func _input(event:InputEvent)->void:
	if _build_menu_open:
		if event is InputEventKey:
			if event.pressed and event.keycode == KEY_ESCAPE:
				build_abort.emit()
				_set_build_menu_open(false)


func _on_world_update_anchors(anchors:Array, location:Vector2i)->void:
	_build_list.clear()
	_anchors = anchors
	_build_location = location
	
	for construction in CONSTRUCTIONS:
		var can_build_construction := false
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


func _add_building_to_list(building:Dictionary)->void:
	_build_list.add_item(building.name)


func _get_construction_by_name(construction_name:String)->Dictionary:
	for construction in CONSTRUCTIONS:
		if construction.name == construction_name:
			return construction
	
	return {}


func _set_build_menu_open(value:bool)->void:
	_build_menu_open = value
	_build_menu.visible = _build_menu_open


func _on_world_open_build_menu()->void:
	_build_menu.clear()
	
	for i in _build_list.item_count:
		_build_menu.add_item(_build_list.get_item_text(i))
	_set_build_menu_open(true)


func _on_world_update_resources(new_resources:Dictionary)->void:
	pass # Replace with function body.


func _on_build_menu_item_selected(index:int)->void:
	var selected_name := _build_menu.get_item_text(index)
	var selected_info := _get_construction_by_name(selected_name)
	build.emit(selected_info, _build_location, _anchors)
	_set_build_menu_open(false)
