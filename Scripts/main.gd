extends Node2D

@onready var combat_scene = preload("res://Scenes/Combat.tscn")
@onready var game_over_scene = preload("res://Scenes/UI/game_over.tscn")
@onready var reward_scene = preload("res://Scenes/UI/Reward.tscn")
@onready var quest_reward_scene = preload("res://Scenes/UI/QuestReward.tscn")

func _ready() -> void:
	SignalBus.connect("enemy_encountered", Callable(self, "start_combat"))
	SignalBus.connect("reward", Callable(self, "show_reward"))
	SignalBus.connect("game_over", Callable(self, "game_over"))

func start_combat():
	add_child(combat_scene.instantiate())

func game_over():
	get_tree().paused = true
	add_child(game_over_scene.instantiate())

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
