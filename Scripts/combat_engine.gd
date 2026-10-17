extends Node2D

@onready var enemies_ref = $Combat/Background_Image/Enemy_Sprites
@onready var player = $Combat/Background_Image/Player
@onready var enemy_res := preload("res://Scenes/Templates/Enemy.tscn")
var action_queue = []
var selected_enemy: Control
var combat_finished = false
var deleted_item_texture: Texture = null

func _ready() -> void:
	await SignalBus.scene_transition_finished
	SignalBus.connect("turn_start", Callable(self, "pop_and_requeue"))
	SignalBus.connect("enemy_selected", Callable(self, "select_enemy"))
	SignalBus.connect("combat_exited", Callable(self, "clean_up"))
	SignalBus.connect("gameover_item_deleted", Callable(self, "set_deleted_item_texture"))
	SignalBus.connect("player_action_selected", Callable(self, "combat_action"))

	print("_ready() combat_engine.gd from maind.gd start_combat()")
	generate_combatants()
	roll_initiative()

func _process(_delta: float) -> void:
	if PlayerData.stat_data["Current_hp"] <= 0:
		if !combat_finished:
			combat_finished = true
			SignalBus.player_died.emit() #goes to equip panel to delete an item
			$Combat/GameOver/ColorRect/VBoxContainer/HBoxContainer/Texture_Rect.texture = deleted_item_texture
			$Combat/GameOver.visible = true
	if CombatData.number_of_enemies == 0:
		$Combat/Background_Image/Action_Panel.visible = false
		if !combat_finished:
			SignalBus.combat_victory.emit(CombatData.reward_data[0],CombatData.reward_data[1])
			combat_finished = true
			if(GameState.biome == "Boss"):
				GameState.biome = "Ruins"

func enqueue(action: Callable):
	action_queue.push_back(action)

func pop_and_requeue(_combatant: String = ""):
	await SignalBus.turn_finished
	var action = action_queue.front()
	if !action_queue.is_empty():
		action_queue.pop_front().call()
		enqueue(action)

func sort_descending(a, b):
	if a[0] == "player" and a[1] == b[1]:
		return true
	elif a[1] > b[1]:
		return true
	return false

func roll_initiative():
	var turn_order: Array[Array] = []
	for c in CombatData.combatants_data.keys():
		if c.contains("player"):
			turn_order.push_front([c, int(PlayerData.get_total_speed())])
		else:
			turn_order.push_front([c, int(CombatData.combatants_data[c]["Speed"])])
	turn_order.sort_custom(sort_descending)
	for t in turn_order:
		if t[0].contains("player"):
			enqueue(Callable(player, "ready_player_turn"))
		else:
			enqueue(Callable(enemies_ref.get_node(t[0]), "ready_enemy_turn"))
	
	for t in turn_order:
		if t[0] != "player":
			pop_and_requeue(t[0])
			break
	SignalBus.turn_finished.emit()

func generate_combatants():
	print("generating combatants...")
	var new_node := enemy_res.instantiate()
	var enemy_stats = GameData.pick_random_enemy()
	var max_enemies = GameData.biome_data[GameState.biome][enemy_stats["enemy_name"]]
	var rand = 0
	if max_enemies == 1:
		rand = 1
	else:
		rand = randi_range(1,max_enemies)#random num of enemies
	for r in rand:
		CombatData.add_combatant(enemy_stats)
		enemies_ref.add_child(new_node.duplicate(), true)
	for c in enemies_ref.get_children():
		c.init()
		selected_enemy = c

func select_enemy(enemy: Control):
	selected_enemy = enemy

func clean_up():
	AudioManager.pause()
	AudioManager.change_to_precombat_song()
	GameState.state = ""
	action_queue = []
	selected_enemy = null
	combat_finished = false
	CombatData.clear_data()
	self.queue_free()

######################
func combat_action(ability: Dictionary):
	#determine target
	var target_enemy = selected_enemy
	#if enemy is dead, pick a valid target
	if target_enemy.visible == false:
		for e in enemies_ref.get_children():
			if e.visible == true:
				target_enemy = e
	#determine target's speed
	var target_spd = CombatData.combatants_data[target_enemy.name]["Speed"]
	#calculate number of actions
	var action_points = 1 + floori(float(PlayerData.get_total_speed() - target_spd) / 4.0)
	if(action_points <= 0): action_points = 1
	
	match ability["Ability_target"]:
		"All_enemies":
			#play attack animation
			await get_tree().create_timer(0.7).timeout
			$Combat/Background_Image/Player.player_action()
			var all_enemies = enemies_ref.get_children()
			change_hp(ability)
			for e in all_enemies:
				if e.visible:
					if roll_to_hit(ability) == true:
						e.on_hit(ceili(roll_damage(ability)))
					else:
						e.on_miss(0)
		"Single_target":
			for a in action_points:
				#play attack animation
				await get_tree().create_timer(0.7).timeout
				$Combat/Background_Image/Player.player_action()
				
				change_hp(ability)
				if roll_to_hit(ability) == true:
					target_enemy.on_hit(roll_damage(ability))
				else:
					target_enemy.on_miss(0)
		"Self_target":
			await get_tree().create_timer(0.7).timeout
			$Combat/Background_Image/Player.player_action()
			$Combat/Background_Image/Player.on_heal(roll_to_buff(ability))
	#REVIEW LATER a check for combat ending should be here
	$Combat/Background_Image/Player.player_finish_turn()

func change_hp(ability: Dictionary) -> void:
	if (PlayerData.stat_data["Current_hp"] + ceili(PlayerData.get_total_hp() * ability["Hp_change_multi"])) >= 1:
		PlayerData.stat_data["Current_hp"] += ceili(PlayerData.get_total_hp() * ability["Hp_change_multi"])
	else:
		PlayerData.stat_data["Current_hp"] = 1
	SignalBus.player_hp_changed.emit()

func roll_to_buff(ability: Dictionary) -> int:
	return randi_range(\
		ceili(PlayerData.get_total_hp() * (ability["Hp_change_multi"] - 0.05)),\
		ceili(PlayerData.get_total_hp() * (ability["Hp_change_multi"] + 0.05)))

func roll_to_hit(ability: Dictionary) -> bool:
	var adjusted_accuracy = PlayerData.stat_data["Accuracy"] + ability["Accuracy_flat"]
	var roll: int = randi_range(0,100)
	if roll >= adjusted_accuracy:
		return false
	else:
		return true

func roll_damage(ability: Dictionary) -> int:
	var damage_min = PlayerData.get_min_damage()
	var damage_max = PlayerData.get_max_damage()
	if ability["Damage_min_flat"] != 0:
		damage_min += ability["Damage_min_flat"]
	if ability["Stat_damage_multiplier"] != 0:
		damage_min += ceili(PlayerData.get_total_stat(ability["Damage_scaling_stat"]) * ability["Stat_damage_multiplier"])
		damage_max += ceili(PlayerData.get_total_stat(ability["Damage_scaling_stat"]) * ability["Stat_damage_multiplier"])
	if ability["Final_damage_multiplier"] != 1:
		damage_min = ceili(damage_min * ability["Final_damage_multiplier"])
		damage_max = ceili(damage_max * ability["Final_damage_multiplier"])
	return randi_range(damage_min, damage_max)
#####################

func _on_button_pressed() -> void:
	clean_up()
	PlayerData.stat_data["Current_hp"] = PlayerData.stat_data["Total_hp"]
	GameState.game_over_reset_flags()
	SignalBus.load_area_entered.emit("Home")
	self.queue_free()
	

func set_deleted_item_texture(item_texture):
	deleted_item_texture = item_texture
