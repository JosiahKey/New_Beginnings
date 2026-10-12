extends Area2D

@export var rarity: String = ""
@export var type: String = ""
@export var quantity: int = 0
var in_range: bool = false
var collected: bool = false

### REVIEW LATER: in-range/interact logic below is duplicated in chest.gd and npc2.gd
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerCursor"):
		if(!collected):
			in_range = true

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerCursor"):
		in_range = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		if in_range and !collected:
			if GameState.quest1_blachsmith_flag == true:
				type = "Weapon"
				rarity = "rare"
			SignalBus.reward.emit("quest")
			for i in quantity:
				SignalBus.reward_generated.emit(type, rarity)
			collected = true
			$AudioStreamPlayer2D.playing = true
