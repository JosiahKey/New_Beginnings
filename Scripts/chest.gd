extends Area2D

@onready var sprite_ref := $TextureRect
@export var rarity: String = ""
@export var type: String = ""
const TYPES = ["Weapon", "Armor", "Jewelry"]
var in_range: bool = false
var collected: bool = false

func _ready() -> void:
	if type == "":
		type = TYPES[randi_range(0,TYPES.size()-1)]
	sprite_ref.texture = load("res://Assets/tile_assets/" + type + "_chest.png")

### REVIEW LATER: in-range/interact logic below is duplicated in npc.gd and npc2.gd
### (could become a shared base script once npc2 is removed with the old overworld)
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
			SignalBus.reward.emit()
			SignalBus.reward_generated.emit(type, rarity)
			collected = true
			$TextureRect.visible = false
			$AudioStreamPlayer2D.playing = true
