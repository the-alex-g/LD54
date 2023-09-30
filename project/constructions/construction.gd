class_name Construction
extends Node2D

signal died

enum {ANCHOR_TOP, ANCHOR_BOTTOM, ANCHOR_LEFT, ANCHOR_RIGHT, ANCHOR_SIDE, ANCHOR_ALL, ANCHOR_NONE}

var anchor : int


func set_anchors(anchors:Array)->void:
	if anchors.size() > 0:
		anchor = anchors.pick_random()
		match anchor:
			ANCHOR_TOP:
				rotation = PI
			ANCHOR_LEFT:
				rotation = TAU / 4
			ANCHOR_RIGHT:
				rotation = -TAU / 4


func kill()->void:
	died.emit()
	queue_free()
