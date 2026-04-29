extends Node

@onready var main: Main
@onready var data:Data = Data.load_or_create()
@export var user_name:String = "skibober"
@export var hard_mode:bool = false
