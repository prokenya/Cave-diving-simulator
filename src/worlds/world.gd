extends Node2D
class_name World
var start_reached:bool = false
var end_reched:bool = false
@onready var player:Player = get_node("player")
@export var intermediate_points_left:Array[CheckPoint]

func check_condition() -> bool:
	if end_reched and start_reached and intermediate_points_left.is_empty():
		G.main.next_world()
		return true
	else:
		return false
