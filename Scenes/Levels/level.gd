extends Node2D
### REVIEW LATER: To be deleted when overworlds are deleted.
### Home.tscn also uses this script, so switch Home to Scripts/level.gd first
### (that script expects Spawns and Load_Zones nodes, so Home would need them
### or a has_node() check added there).

@export var biome: String = ""

func _ready() -> void:
	if biome != "":
		GameState.biome = biome
