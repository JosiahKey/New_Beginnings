extends CanvasLayer

func _on_menu_close_pressed() -> void:
	self.visible = !self.visible
	get_node("SFX_close").playing = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next"):
		if GameState.state != "Combat":
			if visible == true:
				visible = false
				get_node("SFX_close").playing = true
			else:
				visible = true
				get_node("SFX_open").playing = true
