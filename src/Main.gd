extends Node
class_name Main
@export var worlds: Array[PackedScene]
@onready var world: World
@export var gui: GUI
@export var current_world_id: int = 0

func _ready() -> void :
	G.main = self
	gui.set_levels(worlds)

func load_world(index: int = 0):
	get_tree().paused = true
	var instace = worlds[index].instantiate()
	if world:
		world.queue_free()
		await get_tree().process_frame
	world = instace
	add_child(world)
	get_tree().paused = false

func next_world():
	current_world_id += 1
	if current_world_id > worlds.size() - 1:
		gui.show_end()
		return
	gui.load_game(current_world_id)
