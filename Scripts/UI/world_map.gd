extends CanvasLayer

func _ready() -> void:
	SignalBus.connect("world_map_entered", Callable(self, "entered"))

func _on_level_1_pressed() -> void:
	SignalBus.load_area_entered.emit()
	visible = false
	get_tree().paused = false

func _on_level_2_pressed() -> void:
	pass # REVIEW LATER: level 2 button not implemented yet

func _on_level_3_pressed() -> void:
	pass # REVIEW LATER: level 3 button not implemented yet

func entered() ->void:
	get_tree().paused = true
	visible = true
