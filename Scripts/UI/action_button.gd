extends TextureButton

@onready var action_label: Label = $Label

func _ready() -> void:
	pass

func _on_pressed() -> void:
	SignalBus.action_button_pressed.emit("")
	SignalBus.player_action_selected.emit(AbilitiesData.abilities_data[10001])
