class_name DrawingToolSquare
extends DrawingTool
func _gen_points(offset: Vector2)->PackedVector2Array:
	var arr:PackedVector2Array = [
		offset + Vector2(-_R, -_R),
		offset + Vector2(_R, -_R),
		offset + Vector2(_R, _R),
		offset + Vector2(-_R, _R)
	]
	return arr
