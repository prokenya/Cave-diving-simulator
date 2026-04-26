extends StaticBody2D
class_name Polygon2DCollision
var col_poligon:CollisionPolygon2D = CollisionPolygon2D.new()

func _ready() -> void:
	var poligon = get_parent() as Polygon2D
	if poligon:
		col_poligon.polygon = poligon.polygon
		col_poligon.build_mode = CollisionPolygon2D.BUILD_SEGMENTS
	add_child(col_poligon)
