extends CanvasLayer

@onready var heal_label = $Background_Image/Action_Panel/ScrollContainer/Actions_Container/action_button2/Label
@onready var hp_bar: TextureProgressBar = $Background_Image/Stat_Panels/Player_Panel/MarginContainer/Vbox/Player1/HP_Bar/MarginContainer/Health_Prog
@onready var exp_label: Label = $Background_Image/Stat_Panels/Player_Panel/MarginContainer/Vbox/Player1/EXP_Bar/MarginContainer/EXP
@onready var hp_label: Label = $Background_Image/Stat_Panels/Player_Panel/MarginContainer/Vbox/Player1/HP_Bar/MarginContainer/Combat_Hp_Label
@onready var actions_container := $Background_Image/Action_Panel
@onready var enemy_sprites_container = $Background_Image/Enemy_Sprites
@onready var banner_anim := $Background_Image/Turn_Banner/AnimationPlayer
@onready var banner_label := $Background_Image/Turn_Banner/Label
@onready var action1 = $Background_Image/Action_Panel/ScrollContainer/Actions_Container/action_button
@onready var action2 = $Background_Image/Action_Panel/ScrollContainer/Actions_Container/action_button2
@onready var action3 = $Background_Image/Action_Panel/ScrollContainer/Actions_Container/action_button3
@onready var action4 = $Background_Image/Action_Panel/ScrollContainer/Actions_Container/action_button4
@onready var action5 = $Background_Image/Action_Panel/ScrollContainer/Actions_Container/action_button5

var num_of_heals = 2

func _ready() -> void:
	GameState.state = "Combat"
	$Background_Image.texture = load("res://Assets/art_assets/battleback_"+ GameState.biome +".png")

	SignalBus.connect("turn_start", Callable(self, "toggle_action_ui"))
	SignalBus.connect("player_hp_changed", Callable(self, "update_hp"))
	SignalBus.connect("num_enemies_changed", Callable(self, "update_enemy_info"))
	SignalBus.connect("action_button_pressed", Callable(self, "toggle_action_ui"))
	SignalBus.connect("enemy_selected", Callable(self, "select_enemy"))
	
	heal_label.text = "Heal - " + str(num_of_heals) + " left"
	exp_label.text = "EXP: " + str(int(PlayerData.stat_data["Experience"])) + " / " + str(int(PlayerData.stat_data["Exp_to_next_level"]))
	hp_bar.max_value = PlayerData.stat_data["Total_hp"]
	hp_bar.value = PlayerData.stat_data["Current_hp"]
	hp_label.text = "HP: " + str(int(PlayerData.stat_data["Current_hp"])) + " / " + str(int(PlayerData.stat_data["Total_hp"]))
	set_tooltips()

func set_tooltips():
	action1.tooltip_text = "Attack one enemy once... or twice..."\
	+ "\nDamage: " + str(PlayerData.get_min_damage()) + "-" + str(PlayerData.get_max_damage())\
	+ "\nChance to hit: " + str(int(PlayerData.stat_data["Accuracy"])) + "%"
	action2.tooltip_text = "Recover HP \nHeal: 20% (" + str(int(PlayerData.get_total_hp()*0.2))\
	+ ") - 25% (" + str(int(PlayerData.get_total_hp()*0.25)) + ") Max HP\n2 per combat"
	action3.tooltip_text = "Attack all enemies once for 1/3 damage\n and 5% increased hit chance"\
	+ "\nDamage: " + str(int(PlayerData.get_min_damage()/3.0)) + "-" + str(int(PlayerData.get_max_damage()/3.0))\
	+ "\nChance to hit: " + str(int(PlayerData.stat_data["Accuracy"]+5)) + "%"
	action4.tooltip_text = "Don't do it you coward"
	action5.tooltip_text = "Reduces HP by 10% of max HP"\
	+ "\nAttack one enemy once for 25 bonus damage\nper 1 strength with 20% less accuracy"\
	+ "\nDamage: " + str(int(PlayerData.get_min_damage()+ PlayerData.get_total_stength() * 25)) + "-" + str(int(PlayerData.get_max_damage()+ PlayerData.get_total_stength() * 25))\
	+ "\nChance to hit: " + str(int(PlayerData.stat_data["Accuracy"]-20)) + "%"

func update_hp():
	var tween = get_tree().create_tween()
	tween.tween_property(hp_bar, "value", PlayerData.stat_data["Current_hp"], 0.5)
	hp_label.text = "HP: " + str(int(PlayerData.stat_data["Current_hp"])) + " / " + str(int(PlayerData.stat_data["Total_hp"]))

func toggle_action_ui(combatant: String = ""):
	if combatant == "Player":
		if enemy_sprites_container.get_child_count() != 0:
			print(enemy_sprites_container.get_children())
			print(enemy_sprites_container.get_child_count())
			await get_tree().create_timer(0.5).timeout
			actions_container.visible = true
			banner_label.text = "Player Turn"
			banner_anim.play("fadeout")
	else:
		actions_container.visible = false

func _on_reward_visibility_changed() -> void:
	if $Reward.visible == false:
		GameState.state = ""
		SignalBus.combat_exited.emit()
		self.queue_free()

func select_enemy(enemy: Control):
	var nodes = get_tree().get_nodes_in_group("selector")
	for n in nodes:
		n.visible = false
	enemy.get_node("Enemy_Hp/Button/Container/Selector").visible = true

func _on_action_button_pressed() -> void:
	SignalBus.action_button_pressed.emit("")
	SignalBus.player_action_selected.emit(AbilitiesData.abilities_data[10001])

func _on_action_button_2_pressed() -> void:
	if num_of_heals >= 1:
		num_of_heals -= 1
		heal_label.text = "Heal - " + str(num_of_heals) + " left"
		SignalBus.action_button_pressed.emit("")
		SignalBus.player_action_selected.emit(AbilitiesData.abilities_data[10004])
	if num_of_heals <= 0:
		action2.disabled = true

func _on_action_button_3_pressed() -> void:
	SignalBus.action_button_pressed.emit("")
	SignalBus.player_action_selected.emit(AbilitiesData.abilities_data[10002])

func _on_action_button_4_pressed() -> void:
	get_node("select").playing = true
	$Background_Image/Player.player_run_action()
	actions_container.visible = false

func _on_action_button_5_pressed() -> void:
	SignalBus.action_button_pressed.emit("")
	SignalBus.player_action_selected.emit(AbilitiesData.abilities_data[10003])
