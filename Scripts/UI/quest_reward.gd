extends CanvasLayer

@onready var reward_item := preload("res://Scenes/UI/QuestRewardItem.tscn")
@onready var reward_list := $N/ScrollContainer/V
@onready var btns : ButtonGroup = load("res://Resources/quest_reward_button_group.tres")
var ui_iterator = 0

func _ready() -> void:
	SignalBus.connect("update_reward_item", Callable(self, "add_reward_item"))

### REVIEW LATER: duplicated in combat_reward.gd and reward.gd
func add_reward_item(item_id):
	var item_name = GameData.item_data[item_id]["item_name"]
	var new_reward = reward_item.instantiate()
	reward_list.add_child(new_reward, true)
	reward_list.get_child(ui_iterator).set_icon(load("res://Assets/item_assets/"+ item_name +".png"))
	reward_list.get_child(ui_iterator).set_readable_label(item_name)
	reward_list.get_child(ui_iterator).set_item_id(item_id)
	ui_iterator += 1

func _on_confirm_reward_pressed() -> void:
	if btns.get_pressed_button() != null:
		for i in PlayerData.inv_data.keys():
				if PlayerData.inv_data[i]["Item"] == 0:
					PlayerData.inv_data[i]["Item"] = btns.get_pressed_button().get_parent().get_item_id()
					SignalBus.item_collected.emit()
					break
		get_tree().paused = false
		queue_free()
