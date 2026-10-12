extends Control

@onready var sprite : AnimatedSprite2D
@onready var hp_bar: TextureProgressBar
@onready var emitter : GPUParticles2D
@onready var selector: AnimatedSprite2D
@onready var button:= $Enemy_Hp/Button
@onready var floating_text := preload("res://Scenes/UI/floating_text.tscn")

var dead_flag = false
var action_points = 0

func _ready() -> void:
	SignalBus.num_enemies_changed.emit()
	
	sprite = get_node("Enemy_Sprite")
	hp_bar = get_node("Enemy_Hp")
	emitter = get_node("Hit_Indicator")
	selector = get_node("Enemy_Hp/Button/Container/Selector")

func init():
	sprite.sprite_frames = load("res://Resources/" + CombatData.combatants_data[str(name)]["enemy_name"] + ".tres")
	sprite.play("default")
	hp_bar.max_value = CombatData.combatants_data[name]["Max_hp"]
	hp_bar.value = CombatData.combatants_data[name]["Max_hp"]
	CombatData.combatants_data[name]["Current_hp"] = CombatData.combatants_data[name]["Max_hp"]
	button.tooltip_text = GameData.get_readable_enemy_info(CombatData.combatants_data[name])

func ready_enemy_turn():
	sprite.play("default")
	if CombatData.combatants_data[name]["Current_hp"] > 0:
		SignalBus.turn_start.emit(name)
		enemy_action("attack")
		await get_tree().create_timer(0.8).timeout
		sprite.play("default")
	else:
		self.visible = false
		SignalBus.turn_start.emit(name)
		SignalBus.turn_finished.emit()
		if dead_flag == false:
			CombatData.number_of_enemies -= 1
			SignalBus.num_enemies_changed.emit()
			CombatData.add_reward(CombatData.combatants_data[name]["EXP"], CombatData.combatants_data[name]["Loot"])
		dead_flag = true

func enemy_action(action:String):
	match action:
		"attack":
			var target_spd = PlayerData.get_total_speed()
			action_points = 1 + floori(float(CombatData.combatants_data[name]["Speed"]- target_spd) / 4.0)
			if(action_points <= 0): action_points = 1
			for a in action_points:
				sprite.play("attack")
				await get_tree().create_timer(0.5).timeout
				if roll_stat("Accuracy") == true:
					SignalBus.hit_player.emit(randi_range(CombatData.combatants_data[name]["Damage_min"],CombatData.combatants_data[name]["Damage_max"]))
				else:
					SignalBus.miss_player.emit()
				await get_tree().create_timer(0.5).timeout
	sprite.play("default")
	SignalBus.turn_finished.emit()

func roll_stat(stat: String) -> bool:
	var roll: int = randi_range(1,100)
	if roll <= CombatData.combatants_data[name][stat]:
		return true
	else:
		return false

func on_hit(damage):
	if roll_stat("Evasion"):
		var text = floating_text.instantiate()
		text.amount = "Evaded"
		text.type = "evade"
		sprite.add_child(text)
		$enemy_miss.playing = true
	else:
		#midigate damage
		var mitigation = damage - damage * (1 - CombatData.combatants_data[name]["PDR"]/100)
		damage = damage * (1 - CombatData.combatants_data[name]["PDR"]/100)
		if mitigation > 0:
			var text = floating_text.instantiate()
			text.amount = mitigation
			text.type = "block"
			sprite.add_child(text)
		if(damage < 0): damage = 0
		#deal damage
		CombatData.combatants_data[name]["Current_hp"] -= damage
		#move hp bar
		var tween = get_tree().create_tween()
		tween.tween_property(hp_bar, "value", CombatData.combatants_data[name]["Current_hp"], 0.5)
		#animate floating text
		var text2 = floating_text.instantiate()
		text2.amount = damage
		text2.type = "damage"
		sprite.add_child(text2)
		#play damage sprite animation
		sprite.play("damaged")
		#vfx 1shot
		emitter.emitting = true
		#sfx play
		$enemy_hit.playing = true
		#check if dead
		if CombatData.combatants_data[name]["Current_hp"] <= 0:
			await SignalBus.turn_finished
			self.visible = false
		await sprite.animation_finished
		sprite.play("default")

func on_miss(_damage):
	var text = floating_text.instantiate()
	text.amount = "miss"
	text.type = "miss"
	sprite.add_child(text)
	$enemy_miss.playing = true

func _on_button_pressed() -> void:
	SignalBus.enemy_selected.emit(self)
