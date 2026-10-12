extends TextureRect
### REVIEW LATER: this is sperate from equipment item so that we can deal with consumables and stackables later
var highlighted_item_slot := ""
var current_slot = ""

func _get_drag_data(at_position: Vector2):
	var inv_slot = get_parent().get_name()
	if PlayerData.inv_data[inv_slot]["Item"] != 0 and GameData.item_data.has(PlayerData.inv_data[inv_slot]["Item"]):
		var data: Dictionary = {}
		data["origin_node"] = self
		data["origin_panel"] = "Inventory_Panel"
		data["origin_item_id"] = PlayerData.inv_data[inv_slot]["Item"]
		data["origin_equipment_type"] = GameData.item_data[PlayerData.inv_data[inv_slot]["Item"]]["equipmentSlot"]
		data["origin_texture"] = texture
		
		highlighted_item_slot = GameData.item_data[data["origin_item_id"]]["equipmentSlot"]
		SignalBus.highlight_slot.emit(highlighted_item_slot)
		
		var drag_texture = TextureRect.new()
		drag_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		drag_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		drag_texture.texture = texture
		drag_texture.custom_minimum_size = size*1.3
		drag_texture.modulate.a = 0.5
		
		var c := Control.new()
		c.add_child(drag_texture)
		drag_texture.position = Vector2(-at_position)
		set_drag_preview(c)
		
		return data
		
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	var target_slot = get_parent().get_name()
	if PlayerData.inv_data[target_slot]["Item"] == 0:
		data["target_item_id"] = 0
		data["target_texture"] = null
		return true
	else:
		if(!GameData.item_data.has(PlayerData.inv_data[target_slot]["Item"])):
			return false
		data["target_item_id"] = PlayerData.inv_data[target_slot]["Item"]
		data["target_texture"] = texture
		if data["origin_panel"] == "Equip_Panel":
			var target_equipment_slot = GameData.item_data[PlayerData.inv_data[target_slot]["Item"]]["equipmentSlot"]
			if target_equipment_slot == data["origin_equipment_type"]:
				return true
			else:
				return false
		else: #data[origin_panel"] == "Inventory_Panel":
			return true


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var target_equipment_type = get_parent().get_name()
	var origin_slot = data["origin_node"].get_parent().get_name()
	
	#update data of the origin
	if data["origin_panel"] == "Inventory_Panel":
		PlayerData.inv_data[origin_slot]["Item"] = data["target_item_id"]
	else:
		PlayerData.equipment_data[origin_slot] = data["target_item_id"]
		SignalBus.item_equipped.emit()
	
	#update origin text
	data["origin_node"].texture = data["target_texture"]
	
	#update texture and data of target
	PlayerData.inv_data[target_equipment_type]["Item"] = data["origin_item_id"]
	texture = data["origin_texture"]

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.is_pressed():
		if highlighted_item_slot != "":
			SignalBus.unhighlight_slot.emit(highlighted_item_slot)
	### REVIEW LATER: ctrl + LMB auto-equip, unfinished (the "Autoequip" input action exists in project settings)
	#if event.is_action_released("Autoequip"):
		#if current_slot != "":
			#var origin_item_id = PlayerData.inv_data[current_slot]["Item"]
			#var origin_equip_type = GameData.item_data[origin_item_id]["equipmentSlot"]
			#var equipped_item_id = PlayerData.equipment_data[origin_equip_type]
			#this is for ctrl + LMB to auto equip items 
			#but tis going to be hard to implement
			#mainly to swap the textures

func _on_mouse_entered() -> void:
	Tooltip.item_popup(Rect2i(Vector2i(global_position), Vector2i(size)), get_parent().get_name(), "Inventory")
	current_slot = get_parent().get_name()

func _on_mouse_exited() -> void:
	Tooltip.hide_item_popup()
	current_slot = ""
