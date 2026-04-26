@tool
@icon("./icon.svg")
class_name ActionsBinder
extends GridContainer

@export var save_path: String = "user://InputMAP/Map.tres"
@export var cancel_binding_Key: Key = Key.KEY_ESCAPE
@export var actions: ActionsMap = ActionsMap.new()
@export_tool_button("update")
var b = update
@export_tool_button("load_user_actions")
var a = load_actions

var changed_actions: ActionsMap = ActionsMap.new()
var user_actions: Array[StringName] = []

var current_action: ActionBindData
var current_button: Button
var is_binding := false



func _ready() -> void:
	columns = 2
	load_input_map()
	show_actions()


func _input(event: InputEvent) -> void:
	if not is_binding:
		return
	if event is not InputEventKey:
		return
	if not event.pressed:
		return

	var key_event: InputEventKey = event as InputEventKey

	if key_event.keycode == cancel_binding_Key:
		is_binding = false
		current_button.text = get_action_key_name(current_action)
		return

	rebind(current_action, key_event, true)

	current_button.text = key_event.as_text_physical_keycode()
	is_binding = false


func load_actions() -> void:
	InputMap.load_from_project_settings()
	user_actions.clear()

	for action in InputMap.get_actions():
		if action.contains("ui") or action.contains("spatial_editor"):
			continue
		user_actions.append(action)
		var a: ActionBindData = ActionBindData.new()
		a.action_name = action
		var id: int = get_action_id(actions, a)
		if id != -1: return
		actions.actions.append(a)


func update():
	if !Engine.is_editor_hint(): return
	InputMap.load_from_project_settings()
	show_actions()


func show_actions() -> void:
	if !actions.actions: return
	for child: Node in get_children():
		child.queue_free()

	for action: ActionBindData in actions.actions:
		var label: Label = Label.new()
		label.text = action.display_name if action.display_name != "" else action.action_name
		add_child(label)

		var button: Button = Button.new()
		button.text = "   " + get_action_key_name(action) + "   "
		button.pressed.connect(start_binding.bind(action, button))
		button.focus_mode = Control.FOCUS_NONE
		add_child(button)


func get_action_key_name(action: ActionBindData) -> String:
	var events = InputMap.action_get_events(action.action_name)

	if events.is_empty() or events[0] is not InputEventKey:
		return "Unassigned"
	return events[0].as_text_physical_keycode()

func get_action_id(actions_map: ActionsMap, action: ActionBindData):
	return actions_map.actions.find_custom(func(a): return a.action_name == action.action_name)

func start_binding(action: ActionBindData, button: Button) -> void:
	if is_binding:
		current_button.text = get_action_key_name(current_action)
	current_action = action
	current_button = button
	is_binding = true

	button.text = "..."


func rebind(action: ActionBindData, event: InputEventKey = null, save: bool = false):
	var action_name = action.action_name

	if event != null:
		action.event = event

	var events = InputMap.action_get_events(action_name)
	if not events.is_empty():
		InputMap.action_erase_event(action_name, events[0])

	InputMap.action_add_event(action_name, action.event)

	if save:
		var action_to_save: ActionBindData = action.duplicate(true)

		var action_id: int = get_action_id(changed_actions, action)

		if action_id != -1:
			changed_actions.actions[action_id] = action_to_save
		else:
			changed_actions.actions.append(action_to_save)

		save_input_map()


func reset_all():
	changed_actions = ActionsMap.new()
	save_input_map()
	load_input_map()


func save_input_map():
	var dir = save_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_absolute(dir)
	ResourceSaver.save(changed_actions, save_path)


func load_input_map():
	if not ResourceLoader.exists(save_path):
		return
	changed_actions = ResourceLoader.load(save_path)
	if changed_actions == null:
		return
	for i: ActionBindData in changed_actions.actions:
		if i.event != null:
			rebind(i)
