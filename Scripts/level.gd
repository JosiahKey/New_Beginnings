extends Node2D

@onready var player = $Player
@onready var spawns = $Spawns
@onready var exits = $Load_Zones
@export var biome: String = ""

func _ready() -> void:
	if biome != "":
		GameState.biome = biome
	var all_spawns = spawns.get_children()
	var random_spawn = all_spawns[randi()% all_spawns.size()]
	player.global_position = random_spawn.get_global_position()
	var all_exits = exits.get_children()
	var random_exit = all_exits[randi()% all_exits.size()]
	random_exit.disable()
