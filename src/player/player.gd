extends Node2D
class_name Player
@export var body: RigidBody2D
@export var air_timer: Timer
@export var air: float = 120:
	set(val):
		air = val
		if air <= 0:
			air = 0
		if air_progress_bar:
			air_progress_bar.value = air/max_air * 100
		if air <= 0 and head_in_water:
			hp -= 1
@export var air_rate: float = 1
@export var air_rate_curve = Curve.new()
var max_return_air:float = 100
@export var hp: int = 10:
	set(val):
		hp = val
		if hp_progress_bar:
			hp_progress_bar.value = float(hp)/float(max_hp) * 100
		if hp <= 0:
			dead = true
			G.data.dead_players.append(G.user_name)
			G.data.save()
			G.main.gui.show_end("You didn’t manage to reach the exit in time!")

var max_air: float = 100
var max_hp: int = 10


var speed: float = 750
var rotation_speed: float = 5
var in_water: bool = true
var head_in_water: bool = true
var dead:bool = false

@onready var body_area: Area2D = %body_area
@onready var head_area: Area2D = %head_area

@onready var air_progress_bar: ProgressBar = %AirProgressBar
@onready var hp_progress_bar: ProgressBar = %HpProgressBar
@onready var air_rate_label: Label = %air_rate
@onready var intermediate_points: Label = %IntermediatePoints
@onready var hint: Label = %hint
@onready var camera: Camera2D = %Camera2D


func _ready() -> void:
	air_timer.timeout.connect(_on_air_timer_timeout)
	max_air = air
	max_return_air = air/2
	if G.hard_mode:
		camera.ignore_rotation = false
	else:
		camera.ignore_rotation = true
		camera.rotation = 0


func _physics_process(delta: float) -> void:
	if dead:return
	in_water = not body_area.get_overlapping_areas().is_empty()
	head_in_water = not head_area.get_overlapping_areas().is_empty()

	var dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if G.hard_mode:
		dir = dir.rotated(body.rotation)

	if dir:
		var angle_diff = wrapf(body.rotation - dir.angle() - PI / 2, -PI, PI)

		var alignment = max(cos(angle_diff), 0.4)

		var target_velocity = dir * speed * alignment
		body.linear_velocity = lerp(body.linear_velocity, target_velocity, delta)
	var rotation_dir: float = Input.get_axis("rotate_left", "rotate_right")
	if rotation_dir:
		body.angular_velocity = lerp(body.angular_velocity, rotation_dir * rotation_speed, delta)

	if in_water:
		body.gravity_scale = 1
	else:
		body.gravity_scale = 100
	intermediate_points.text = "Points of interest left: " + str(G.main.world.intermediate_points_left.size())

	if G.main.gui.show_hints:
		hint.show()
	else:
		hint.hide()
	if G.main.world.end_reched:
		if G.main.world.intermediate_points_left.size() == 0:
			hint.text = "hint: end reached, return to the start"
		else:
			hint.text = "hint: end reached,go through all the intermediate points and then return to the start"
	

func _on_air_timer_timeout():
	if G.hard_mode:
		G.main.world.player.camera.ignore_rotation = false
	else:
		G.main.world.player.camera.ignore_rotation = true
		G.main.world.player.camera.rotation = 0
	var delta:float = air_rate * air_rate_curve.sample(head_area.global_position.y)
	if head_in_water:
		air -= delta
		air_rate_label.text = "air consumption rate: -" + str(round(delta * 10)/10) + " units/sec"
		return
	elif air < max_return_air:
		air += air_rate
		air_rate_label.text = "air consumption rate: +" + str(air_rate) + " units/sec"
		return
	#print(str(delta) + " air -> " + str(air))
	air_rate_label.text = "air consumption rate: " + str(0) + " units/sec"
	
