extends CanvasLayer

@onready var exp_bar: TextureProgressBar = $N/V/exp_reward/expbar
@onready var exp_text: Label = $N/V/exp_reward/expbar/Label
@onready var level_label: Label = $N/V/exp_reward/Lvl_Text/stat_label
@onready var btn := $N/confirm_reward
@onready var reward_item := preload("res://Scenes/UI/reward_item.tscn")
@onready var reward_list := $N/V
var exp_finished_flag = false
var ui_iterator = 2

func _ready() -> void:
	SignalBus.connect("update_reward_item", Callable(self, "add_reward_item"))
	SignalBus.connect("exp_finished", Callable(self, "allow_button"))
	SignalBus.connect("combat_victory", Callable(self, "combat_victory"))
	SignalBus.connect("check_for_levelup", Callable(self, "check_for_levelup")) 
	
	exp_bar.max_value = PlayerData.stat_data["Exp_to_next_level"]
	exp_bar.value = PlayerData.stat_data["Experience"]
	btn.visible = true

func combat_victory(experience: int, loot: int):
	#play fanfare
	AudioManager.pause()
	get_node("fanfare").playing = true
	await get_tree().create_timer(1.0).timeout
	#reward popup + EXP gain animation
	level_label.text = "Level " + str(PlayerData.stat_data["Level"])
	exp_text.text = "+"+str(experience)
	self.visible = true
	for l in loot:
		var loot_roll = randi_range(1,100)
		if loot_roll < 40:
			SignalBus.reward_generated.emit()
	check_for_levelup(experience)
	SignalBus.update_stat_panel.emit()

func check_for_levelup(experience: float = 0.0):
	exp_bar.max_value = PlayerData.stat_data["Exp_to_next_level"]
	var exptween = get_tree().create_tween()
	var newexp = PlayerData.stat_data["Experience"] + experience
	PlayerData.stat_data["Experience"] += experience
	
	if(PlayerData.stat_data["Experience"] >= PlayerData.stat_data["Exp_to_next_level"]):
		var difference = PlayerData.stat_data["Experience"] - PlayerData.stat_data["Exp_to_next_level"]
		PlayerData.stat_data["Level"] += 1
		PlayerData.stat_data["Exp_to_next_level"] = float(int(600 * (PlayerData.stat_data["Level"] ** 2)-(600 * PlayerData.stat_data["Level"])))
		PlayerData.stat_data["Experience"] = difference
		exptween.tween_property(exp_bar, "value", exp_bar.max_value, 1.5).set_ease(Tween.EASE_OUT)
		await exptween.finished
		SignalBus.levelup.emit()
	else:
		exptween.tween_property(exp_bar, "value", newexp, 1.0).set_ease(Tween.EASE_OUT)
	
	level_label.text = "Level " + str(PlayerData.stat_data["Level"])
	await exptween.finished
	SignalBus.exp_finished.emit()

func add_reward_item(item_id):
	var item_name = GameData.item_data[item_id]["item_name"]
	var new_reward = reward_item.instantiate()
	reward_list.add_child(new_reward, true)
	reward_list.get_child(ui_iterator).set_icon(load("res://Assets/item_assets/"+ item_name +".png"))
	reward_list.get_child(ui_iterator).set_readable_label(item_name)
	reward_list.get_child(ui_iterator).set_item_id(item_id)
	ui_iterator += 1

func _on_confirm_reward_pressed() -> void:
	if(exp_finished_flag):
		for c in reward_list.get_children():
			c.queue_free()
		AudioManager.change_to_precombat_song()
		visible = false
		btn.visible = false
		exp_finished_flag = false
		ui_iterator = 2

func allow_button():
	exp_finished_flag = true
