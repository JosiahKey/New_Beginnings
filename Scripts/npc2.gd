extends Area2D

var in_range: bool = false

### REVIEW LATER: in-range/interact logic below is duplicated in chest.gd and npc.gd
### (npc2 is the old-overworld merchant; goes away when the overworlds are deleted)
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerCursor"):
		in_range = true

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerCursor"):
		in_range = false
		$Dialouge.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		if in_range:
			$Dialouge.visible = true
			GameState.quest1_blachsmith_flag = true
