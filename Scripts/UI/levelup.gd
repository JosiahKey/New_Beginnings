extends CanvasLayer

@onready var label:= $N/V/StatChange/Label
var choice := "Health"

func  _ready() -> void:
	SignalBus.connect("levelup", Callable(self, "levelup"))

func levelup():
	visible = true

func _input(event: InputEvent) -> void:
	#debug key (L): only works in the editor and debug exports, not release builds
	if OS.is_debug_build() and event.is_action_pressed("debuglevelup"):
		visible = true

func _on_health_pressed() -> void:
	label.text = "Max Health\n+100"
	choice = "Health"

func _on_strength_pressed() -> void:
	label.text = "Strength\n+2"
	choice = "Strength"

func _on_speed_pressed() -> void:
	label.text = "Speed\n+2"
	choice = "Speed"

func _on_confirm_pressed() -> void:
	PlayerData.stat_data["Current_hp"] = PlayerData.stat_data["Total_hp"]
	if choice == "Health":
		PlayerData.stat_data["Natural_hp"] += 100
		PlayerData.stat_data["Current_hp"] += 100
	if choice == "Strength":
		PlayerData.stat_data["Strength"] += 2
	if choice == "Speed":
		PlayerData.stat_data["Speed"] += 2

	SignalBus.update_stat_panel.emit()
	SignalBus.check_for_levelup.emit()
	visible = false
