class_name GUI
extends CanvasLayer

var is_in_ui: bool = true
var is_in_guide: bool = false
var show_hints:bool = false
var transition_tween

var is_in_settings: bool = false

@onready var gui_animations: AnimationPlayer = %guianimation

@onready var transition: ColorRect = %transition
@onready var end_label: Label = %end_label

@onready var sfx_spin_box: SpinBox = %SFXSpinBox
@onready var music_spin_box: SpinBox = %music_spin_box
@onready var main_menu_button: Button = %main_menu_button
@onready var play: Button = %Play

@onready var resume_button: Button = % "resume button"
@onready var settings: Button = % "settings"
@onready var guide: Button = %guide

@onready var levels_c: VBoxContainer = %levels
@onready var end: CanvasLayer = %end
@onready var name_line: LineEdit = %name_line


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_audio()
	play.pressed.connect(_on_play_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	settings.pressed.connect(_on_settings_pressed)
	guide.pressed.connect(_on_guide_pressed)
	resume_button.pressed.connect(open_close_menu)
	
	sfx_spin_box.value_changed.connect(_on_spinsfx_value_changed)
	music_spin_box.value_changed.connect(_on_spinmusic_value_changed)
	


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Menu"):
		open_close_menu()


func set_audio():
	var bus_index = AudioServer.get_bus_index("sfx")
	var bus_index1 = AudioServer.get_bus_index("music")
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(G.data.sfx)
	)
	AudioServer.set_bus_volume_db(
		bus_index1,
		linear_to_db(G.data.music)
	)
	sfx_spin_box.value = G.data.sfx * 100
	music_spin_box.value = G.data.music * 100


func set_levels(levels: Array):
	for i in range(levels.size()):
		var button = Button.new()
		button.text = "level: " + str(i + 1)
		button.focus_mode = Control.FOCUS_NONE

		button.set_meta("level_id", i)
		button.connect("pressed", _on_play_pressed.bind(i))
		levels_c.add_child(button)
		set_buttons_status({ "active_buttons": G.data.active_buttons })


func set_buttons_status(data: Dictionary):
	var active_buttons = data.get("active_buttons")

	for button in levels_c.get_children():
		if button.get_meta("level_id") in active_buttons:
			button.disabled = false
		else:
			button.disabled = true


func load_game(id: int = 0):
	await set_transition()
	G.main.load_world(id)
	G.main.current_world_id = id
	hide_buttons()
	await set_transition(false)
	if id not in G.data.active_buttons:
		G.data.active_buttons.append(id)
		G.data.save()
		set_buttons_status({ "active_buttons": G.data.active_buttons })


func hide_buttons():
	main_menu_button.visible = true

	resume_button.visible = true

	play.visible = false
	name_line.hide()


func open_close_menu(trusted: bool = false):
	if gui_animations.is_playing():
		return
	if is_in_ui:
		if is_in_guide:
			gui_animations.play_backwards("show guide")
			await gui_animations.animation_finished
			is_in_guide = false
		if is_in_settings:
			gui_animations.play_backwards("show settings")
			await gui_animations.animation_finished
			is_in_settings = false

		if not G.main.world and not trusted: return

		gui_animations.play_backwards("show menu")
		await gui_animations.animation_finished
	else:
		gui_animations.play("show menu")
		get_tree().paused = !is_in_ui
		await gui_animations.animation_finished

	is_in_ui = !is_in_ui
	get_tree().paused = is_in_ui


func set_transition(start: bool = true, color: Color = Color.BLACK) -> void:
	if transition_tween:
		transition_tween.kill()
	transition_tween = create_tween()
	if start:
		transition.visible = true
		transition_tween.tween_property(transition, "color", color, 1)
		await transition_tween.finished
	else:
		transition_tween.tween_property(transition, "color", Color("#00000000"), 1)
		await transition_tween.finished
		transition.visible = false
	return


func show_end(text: String = ""):
	#get_tree().paused = true
	if text != "":
		end_label.text = text
	end.show()
	await get_tree().create_timer(5).timeout
	_on_main_menu_pressed()


func _on_play_pressed(id: int = 0) -> void:
	print(name_line.text)
	if name_line.text == "":
		OS.alert("write name!")
		return
	G.user_name = name_line.text
	if G.user_name in G.data.dead_players:
		OS.alert("this one died!")
		return
	open_close_menu(true)
	load_game(id)


func _on_main_menu_pressed() -> void:
	await set_transition()
	if G.main.world.player.head_in_water:
		G.data.dead_players.append(G.user_name)
	G.data.save()
	G.main.current_world_id = 0
	get_tree().change_scene_to_file("res://src/main.tscn")

	await set_transition(false)


func _on_settings_pressed() -> void:
	if gui_animations.current_animation == &"show guide":
		await gui_animations.animation_finished
	if is_in_settings:
		gui_animations.play_backwards("show settings")
	else:
		gui_animations.play("show settings")
	is_in_settings = !is_in_settings


func _on_guide_pressed() -> void:
	if gui_animations.current_animation == &"show settings":
		await gui_animations.animation_finished
	if is_in_guide:
		gui_animations.play_backwards("show guide")
	else:
		gui_animations.play("show guide")
	is_in_guide = !is_in_guide


func _on_spinsfx_value_changed(value: float) -> void:
	G.data.sfx = value / 100
	G.data.save()
	set_audio()


func _on_spinmusic_value_changed(value: float) -> void:
	G.data.music = value / 100
	G.data.save()
	set_audio()


func _on_show_hint_pressed() -> void:
	show_hints = !show_hints


func _on_show_hint_2_toggled(toggled_on: bool) -> void:
	G.hard_mode = toggled_on
		
