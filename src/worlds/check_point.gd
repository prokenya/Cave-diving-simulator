@tool
class_name CheckPoint
extends Area2D

enum states {
	Start,
	End,
	Intermediate,
	Reached,
}

@export var state: states = states.Start:
	set(val):
		state = val
		if state != states.Reached:
			if sprite_2d:
				sprite_2d.texture = sprites[state]
		else:
			audio_stream_player.play()
			status.show()
@export var sprites: Array[CompressedTexture2D]

@onready var status: Sprite2D = $status
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_mask_value(3, true)
	body_entered.connect(_on_body_entered)
	state = state


func _on_body_entered(body: Node2D):
	var parent: Player = body.get_parent()
	if parent is not Player: return
	if state == states.Reached: return
	match state:
		states.Start:
			if G.main.world.end_reched and G.main.world.intermediate_points_left.is_empty():
				G.main.world.start_reached = true
				G.main.world.check_condition()
				state = states.Reached
		states.End:
			G.main.world.end_reched = true
			state = states.Reached
		states.Intermediate:
			state = states.Reached
			G.main.world.intermediate_points_left.erase(self)
	#print(body)
