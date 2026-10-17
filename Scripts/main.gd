extends Node2D

@onready var combat_scene = preload("res://Scenes/Combat.tscn")
@onready var reward_scene = preload("res://Scenes/UI/Reward.tscn")
@onready var quest_reward_scene = preload("res://Scenes/UI/QuestReward.tscn")

func _ready() -> void:
	SignalBus.connect("enemy_encountered", Callable(self, "start_combat"))
	SignalBus.connect("reward", Callable(self, "show_reward"))

func start_combat():
	add_child(combat_scene.instantiate())
	print("start_combat() via enemy_encountered signal")

func show_reward(type: String = "normal"):
	if type == "normal":
		get_tree().paused = true
		add_child(reward_scene.instantiate())
	if type == "quest":
		get_tree().paused = true
		add_child(quest_reward_scene.instantiate())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("hidehint"):
		$ControlsHint.visible = !$ControlsHint.visible
