extends Node2D

@export var min_bubble_radius := 8
@export var max_bubble_radius := 16

@onready var _tilemap : TileMap = $TileMap


func _ready()->void:
	_generate_bubble(Vector2i(20, 20), 8)


func _generate_bubble(at:Vector2i, radius:int)->void:
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			if pow(x, 2) + pow(y, 2) < pow(radius + 1, 2) and pow(x, 2) + pow(y, 2) >= pow(radius, 2):
				_tilemap.set_cell(0, Vector2i(x, y) + at, 0, Vector2i.ZERO)
