extends Resource
class_name ActionBindData

## Name of the action as defined in InputMap
@export var action_name: StringName

## Optional display name (uses action_name if empty)
@export var display_name: String = ""

## Assigned key event (set automatically at runtime)
@export var event: InputEventKey
