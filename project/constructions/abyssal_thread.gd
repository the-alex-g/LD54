class_name AbyssalThread
extends Construction


func _ready()->void:
	modulate = Color(Color.WHITE, 0.0)
	get_tree().create_tween().set_trans(Tween.TRANS_QUAD).tween_property(self, "modulate", Color.WHITE, 1.0)
