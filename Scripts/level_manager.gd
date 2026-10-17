extends Node2D

@onready var home: String = "res://Scenes/Levels/Cave/Home.tscn"
@onready var caves: String = "res://Scenes/Levels/Cave/Caves.tscn"
@onready var catacombs: String = "res://Scenes/Levels/Cave/Catacombs.tscn"
@onready var garden: String = "res://Scenes/Levels/Cave/Garden.tscn"
@onready var nave: String = "res://Scenes/Levels/Cave/Nave.tscn"
@onready var tower: String = "res://Scenes/Levels/Cave/Tower.tscn"
@onready var ordered_level_list = [home, caves, catacombs, garden, nave, tower]
@onready var current_level_index = 0

func _ready() -> void:
	SignalBus.connect("load_area_entered", Callable(self, "load_level"))

func load_level() -> void:
	if(get_child_count() > 0 and GameState.state != "Combat"):
		get_child(0).queue_free()
	if !_checkpoint_floor():
		var level_res = load(ordered_level_list[current_level_index])
		call_deferred("add_child", level_res.instantiate())

func _checkpoint_floor() -> bool:
	if current_level_index >= 5:
		var home_res = load(home)
		call_deferred("add_child", home_res.instantiate())
		current_level_index = 0
		return true
	else:
		current_level_index += 1
		return false
