extends Control

var custom = load("res://Assets/gui_assets/cursor_forbidden.png")

func _ready() -> void:
	Input.set_custom_mouse_cursor(custom, Input.CURSOR_FORBIDDEN)
	Input.set_custom_mouse_cursor(custom, Input.CURSOR_CAN_DROP)

func item_popup(slot_pos: Rect2i, slot: String, origin: String):
	var valid = false
	var item_id: int
	if origin == "Inventory":
		if PlayerData.inv_data[slot]["Item"] != null and GameData.item_data.has(PlayerData.inv_data[slot]["Item"]):
			item_id = PlayerData.inv_data[slot]["Item"]
			valid = true
			%Tooltip.show()
			%Tooltip.position = Vector2i(slot_pos.position - Vector2i(328,200))
		else:
			valid = false
	else: #origin equipment
		if PlayerData.equipment_data[slot] != null and GameData.item_data.has(PlayerData.equipment_data[slot]):
			item_id = PlayerData.equipment_data[slot]
			valid = true
			%Tooltip.show()
			%Tooltip.position = Vector2i(slot_pos.position - Vector2i(308,200))
		else:
			valid = false
	if valid:
		clear_text()
		get_node("CanvasLayer/Tooltip/M/V/Item_Name").text = GameData.item_data[item_id]["item_name"]
		get_node("CanvasLayer/Tooltip/M/V/Item_Name").add_theme_color_override("font_color", Color(get_name_color(GameData.item_data[item_id]["item_rarity"])))
		get_node("CanvasLayer/Tooltip/M/V/Item_Slot").text = "Equipment Slot: " + GameData.item_data[item_id]["equipmentSlot"]
		var ui_iterator = 1
		for i in range(GameData.item_stats.size()):
			var stat_name = GameData.item_stats[i]
			var stat_readable = GameData.item_stats_readable[i]
			var equipped_id = PlayerData.equipment_data[GameData.item_data[item_id]["equipmentSlot"]]
			if(equipped_id == 0):
				equipped_id = item_id
			if (GameData.item_data[item_id][stat_name] != 0 or GameData.item_data[equipped_id][stat_name] != 0):
				var stat_value = int(GameData.item_data[item_id][stat_name])
				get_node("CanvasLayer/Tooltip/M/V/Stat" + str(ui_iterator) + "/Stat").text = stat_readable + ": +" + str(stat_value)
				if GameData.item_data[item_id]["equipmentSlot"] != null and origin == "Inventory":
					var stat_diff = compare_items(item_id, stat_name, stat_value)
					if stat_diff > 0:
						get_node("CanvasLayer/Tooltip/M/V/Stat" + str(ui_iterator) + "/Diff").text = "+" + str(stat_diff) + "       "
						get_node("CanvasLayer/Tooltip/M/V/Stat" + str(ui_iterator) + "/Diff").add_theme_color_override("font_color", Color("2eff27"))
					elif stat_diff < 0:
						get_node("CanvasLayer/Tooltip/M/V/Stat" + str(ui_iterator) + "/Diff").text = str(stat_diff) + "       "
						get_node("CanvasLayer/Tooltip/M/V/Stat" + str(ui_iterator) + "/Diff").add_theme_color_override("font_color", Color("ff3131"))
					else:
						get_node("CanvasLayer/Tooltip/M/V/Stat" + str(ui_iterator) + "/Diff").text = "0       "
						get_node("CanvasLayer/Tooltip/M/V/Stat" + str(ui_iterator) + "/Diff").add_theme_color_override("font_color", Color("003131ff"))
				else:
					get_node("CanvasLayer/Tooltip/M/V/Stat" + str(ui_iterator) + "/Diff").text = "0       "
					get_node("CanvasLayer/Tooltip/M/V/Stat" + str(ui_iterator) + "/Diff").add_theme_color_override("font_color", Color("003131ff"))
				ui_iterator += 1
		
	else:
		%Tooltip.hide()

func hide_item_popup():
	%Tooltip.hide()

func clear_text():
	for i in range(1, 9):   #Stat1 to Stat8
		get_node("CanvasLayer/Tooltip/M/V/Stat%d/Stat" % i).text = ""
		get_node("CanvasLayer/Tooltip/M/V/Stat%d/Diff" % i).text = ""

func get_name_color(item_rarity: String) -> Color:
	if(item_rarity == "common"):
		return Color("673f11ff")
	if(item_rarity == "uncommon"):
		return Color("c9c9c6ff")
	if(item_rarity == "rare"):
		return Color("1e5ed2ff")
	if(item_rarity == "epic"):
		return Color("007647ff")
	if(item_rarity == "legendary"):
		return Color("b7152fff")
	else:
		return Color("000000ff")

func compare_items(item_id, stat_name, stat_value):
	var stat_diff = 0
	var slot = GameData.item_data[item_id]["equipmentSlot"]
	if PlayerData.equipment_data[slot] != 0:
		var equipped_item_id = PlayerData.equipment_data[slot]
		var equipped_item_stat_value = GameData.item_data[equipped_item_id][stat_name]
		stat_diff = stat_value - equipped_item_stat_value
		if PlayerData.equipment_data[slot] == item_id:
			return 0
	else:
		stat_diff = stat_value
	return int(stat_diff)
