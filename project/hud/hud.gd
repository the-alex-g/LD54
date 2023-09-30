class_name HUD
extends CanvasLayer

signal build(info, location, anchors)

const CONSTRUCTIONS := [
	{"name":"Glowing Algae", "anchors":[Construction.ANCHOR_ALL], "anchors_exclude":[], "cost":{}, "path":"res://constructions/glowing_algae.tscn"},
	{"name":"Detritivores", "anchors":[Construction.ANCHOR_BOTTOM], "anchors_exclude":[], "cost":{}, "path":"res://constructions/detritivores.tscn"},
	{"name":"Mussel Bed", "anchors":[Construction.ANCHOR_BOTTOM, Construction.ANCHOR_SIDE], "anchors_exclude":[], "cost":{}, "path":"res://constructions/mussel_bed.tscn"},
	{"name":"Harvester", "anchors":[Construction.ANCHOR_NONE], "anchors_exclude":[Construction.ANCHOR_ALL], "cost":{}, "path":"res://constructions/harvester.tscn"},
	{"name":"Harvester Spawn", "anchors":[Construction.ANCHOR_BOTTOM], "anchors_exclude":[], "cost":{}, "path":"res://constructions/harvester_spawn.tscn"},
]

var _build_location := Vector2i.ZERO
var _anchors := []
var _resources := {"light":0, "chitin":0, "threads":0,}
var _can_build := true

@onready var _build_list : ItemList = $Control/BuildList


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


func _on_world_update_resources(resource:String)->void:
	_resources[resource] += 1


func _on_world_build_invalid()->void:
	_build_list.clear()
	_can_build = false


func _on_build_list_item_selected(index:int)->void:
	var selected_name := _build_list.get_item_text(index)
	var selected_info := _get_construction_by_name(selected_name)
	_spend_resources(selected_info.cost)
	build.emit(selected_info.path, _build_location, _anchors)
