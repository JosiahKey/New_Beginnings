extends NinePatchRect

@onready var grid_ref := $GridContainer

func _ready() -> void:
	SignalBus.connect("item_equipped", Callable(self, "_update_equipped_stats"))
	SignalBus.connect("highlight_slot", Callable(self, "highlight_slot"))
	SignalBus.connect("unhighlight_slot", Callable(self, "unhighlight_slot"))
	SignalBus.connect("player_died", Callable(self, "delete_random_item"))
	_update_equipped_items()
	_update_equipped_stats()

func _update_equipped_items():
	for i in PlayerData.equipment_data.keys():
		if PlayerData.equipment_data[i] != null and GameData.item_data.has(PlayerData.equipment_data[i]):
			var item_name:String  = GameData.item_data[PlayerData.equipment_data[i]]["item_name"]
			var icon_texture:Texture =  load("res://Assets/item_assets/"+ item_name +".png")
			grid_ref.get_node(str(i)+ "/" + str(i) + "/Icon").texture = icon_texture

func _update_equipped_stats():
	get_node("equip").playing = true
	PlayerData.stat_data["Total_equipped_weight"] = 0
	PlayerData.stat_data["Total_equipped_damage_min"] = 0
	PlayerData.stat_data["Total_equipped_damage_max"] = 0
	PlayerData.stat_data["Bonus_hp"] = 0
	PlayerData.stat_data["Accuracy"] = 0
	PlayerData.stat_data["Evasion"] = 0
	PlayerData.stat_data["PDR"] = 0
	PlayerData.stat_data["Bonus_strength"] = 0
	PlayerData.stat_data["Bonus_speed"] = 0

#no mainhand equipped
	if PlayerData.equipment_data["Mainhand"] == 0:
		PlayerData.stat_data["Total_equipped_damage_min"] = 0
		PlayerData.stat_data["Total_equipped_damage_max"] = 0
		PlayerData.stat_data["Accuracy"] = 100

	for i in PlayerData.equipment_data.keys():
		if PlayerData.equipment_data[i] != null and GameData.item_data.has(PlayerData.equipment_data[i]):
			PlayerData.stat_data["Bonus_hp"] += GameData.item_data[
									PlayerData.equipment_data[i]]["Hp"]
			PlayerData.stat_data["Accuracy"] += GameData.item_data[
									PlayerData.equipment_data[i]]["Accuracy"]
			PlayerData.stat_data["Evasion"] += GameData.item_data[
									PlayerData.equipment_data[i]]["Evasion"]
			PlayerData.stat_data["PDR"] += GameData.item_data[
									PlayerData.equipment_data[i]]["PDR"]
			PlayerData.stat_data["Bonus_strength"] += GameData.item_data[
									PlayerData.equipment_data[i]]["Strength"]
			PlayerData.stat_data["Bonus_speed"] += GameData.item_data[
									PlayerData.equipment_data[i]]["Speed"]
			### REVIEW LATER: Weight stat not implemented yet (also see stat_panel.gd tooltip)
			#PlayerData.stat_data["Total_equipped_weight"] += GameData.item_data[
									#PlayerData.equipment_data[i]]["Weight"]
			PlayerData.stat_data["Total_equipped_damage_min"] += GameData.item_data[
									PlayerData.equipment_data[i]]["Damage_min"]
			PlayerData.stat_data["Total_equipped_damage_max"] += GameData.item_data[
									PlayerData.equipment_data[i]]["Damage_max"]
	
	#if min damage is too high
	if PlayerData.stat_data["Total_equipped_damage_min"] > PlayerData.stat_data["Total_equipped_damage_max"]:
		PlayerData.stat_data["Total_equipped_damage_max"] = PlayerData.stat_data["Total_equipped_damage_min"]
	SignalBus.update_stat_panel.emit()
	
	#if current hp is higher than new hp max
	if PlayerData.stat_data["Current_hp"] > PlayerData.stat_data["Total_hp"]:
		PlayerData.stat_data["Current_hp"] = PlayerData.stat_data["Total_hp"]

func highlight_slot(slot: String):
	get_node("GridContainer/" + slot + "/" + slot + "/Highlight").visible = true

func unhighlight_slot(slot: String):
	get_node("GridContainer/" + slot + "/" + slot + "/Highlight").visible = false

func delete_random_item():
	var equipped_items = []
	for k in PlayerData.equipment_data.keys():
		if PlayerData.equipment_data[k] != 0:
			equipped_items.append(k)
	if equipped_items.size()-1 >= 0:
		var i = randi_range(0, equipped_items.size()-1)
		PlayerData.equipment_data[equipped_items[i]] = 0
		_update_equipped_items()
		_update_equipped_stats()
		SignalBus.gameover_item_deleted.emit(grid_ref.get_node(equipped_items[i]+ "/" + equipped_items[i] + "/Icon").texture)
		grid_ref.get_node(equipped_items[i]+ "/" + equipped_items[i] + "/Icon").texture = null
