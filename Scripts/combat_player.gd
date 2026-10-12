extends Control

@onready var player_spr: AnimatedSprite2D = $Player_Sprite
@onready var emitter: GPUParticles2D = $Hit_Indicator
@onready var floating_text := preload("res://Scenes/UI/floating_text.tscn")

func _ready() -> void:
	SignalBus.connect("hit_player", Callable(self,"on_hit"))
	SignalBus.connect("miss_player", Callable(self,"on_miss"))

func ready_player_turn():
	SignalBus.turn_start.emit(name)
	player_spr.play("idle")

func player_run_action():
	var roll = randi_range(1,100)
	if roll > 50:
		SignalBus.combat_exited.emit()
	else:
		on_miss()
		player_spr.play("attack")
		player_finish_turn()

func roll_stat(stat: String, adjusted_accuracy: int = 0) -> bool:
	var roll: int = randi_range(0,100)
	if stat == "Accuracy" and adjusted_accuracy != 0:
		if roll >= PlayerData.stat_data[stat]+adjusted_accuracy:
			return false
		else:
			return true
	else:
		if roll >= PlayerData.stat_data[stat]:
			return false
		else:
			return true

func on_hit(damage: int):
	if(roll_stat("Evasion")):
		var text = floating_text.instantiate()
		text.amount = "Evaded"
		text.type = "evade"
		player_spr.add_child(text)
		$player_miss.playing = true
	else:
		#midigate damage
		var mitigation = damage - roundi(float(damage) * (1.0 - float(PlayerData.stat_data["PDR"])/100.0))
		damage = roundi(float(damage) * (1.0 - float(PlayerData.stat_data["PDR"])/100.0))
		if mitigation > 0:
			var text2 = floating_text.instantiate()
			text2.amount = mitigation
			text2.type = "block"
			player_spr.add_child(text2)
		if(damage < 0): damage = 0
		#deal damage
		PlayerData.stat_data["Current_hp"] -= damage
		#update hp label
		SignalBus.player_hp_changed.emit()
		#animate floating text
		var text = floating_text.instantiate()
		text.amount = damage
		text.type = "damage"
		player_spr.add_child(text)
		#play damage sprite animation
		player_spr.play("damaged")
		#vfx 1shot
		emitter.emitting = true
		#sfx play
		get_node("player_hit").playing = true
		await player_spr.animation_finished
		player_spr.play("idle")

func on_miss():
	var text = floating_text.instantiate()
	text.amount = "miss"
	text.type = "miss"
	player_spr.add_child(text)
	$player_miss.playing = true

func on_heal(heal: int):
	var adjusted_heal = heal
	#heal damage
	if(PlayerData.stat_data["Current_hp"] + heal > PlayerData.stat_data["Total_hp"]):
		adjusted_heal = PlayerData.stat_data["Total_hp"] - PlayerData.stat_data["Current_hp"]
		PlayerData.stat_data["Current_hp"] = PlayerData.stat_data["Total_hp"]
	else:
		PlayerData.stat_data["Current_hp"] += heal
	#update hp label
	SignalBus.player_hp_changed.emit()
	#sfx
	$player_heal.playing = true
	#floating text
	var text = floating_text.instantiate()
	text.amount = adjusted_heal
	text.type = "heal"
	player_spr.add_child(text)
	await player_spr.animation_finished
	player_spr.play("idle")

func player_action():
	player_spr.play("attack")

func player_finish_turn():
	await player_spr.animation_finished
	player_spr.play("idle")
	SignalBus.turn_finished.emit()

func _on_player_sprite_animation_finished() -> void:
	player_spr.play("idle")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("run_away"):
		SignalBus.combat_exited.emit()
