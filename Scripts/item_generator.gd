extends Node2D

#the item genreation below is(should be) totally static and could be 
# in any script file just testing it here for now
func _ready() -> void:
	SignalBus.connect("reward_generated", Callable(self, "generate_reward"))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debuggenerateitem"):
		generate_item("","rare","")

func generate_reward(type: String = "", rarity: String = "", slot: String = ""):
	var new_item = ItemGeneration(type, rarity, slot)
	var item_id: int = new_item.keys()[0]
	GameData.item_data.merge(new_item)
	SignalBus.update_reward_item.emit(item_id)

func generate_item(type: String = "", rarity: String = "", slot: String = ""):
	var new_item = ItemGeneration(type, rarity, slot)
	var item_id: int = new_item.keys()[0]
	GameData.item_data.merge(new_item)
	for i in PlayerData.inv_data.keys():
			if PlayerData.inv_data[i]["Item"] == 0:
				PlayerData.inv_data[i]["Item"] = item_id
				SignalBus.item_collected.emit()
				break

func ItemGeneration(type: String = "", rarity: String = "", slot: String = "") -> Dictionary:
	var new_item: Dictionary = {}
	var new_item_dict: Dictionary = {}
	new_item["item_id"] = ItemDetermineType(type,slot)
	new_item["item_rarity"] = ItemDetermineRarity(rarity)
	new_item["item_name"] = ItemDetermineName(new_item["item_id"], new_item["item_rarity"])
	new_item["equipmentSlot"] = GameData.base_item_data[new_item["item_id"]]["equipmentSlot"]
	new_item["Type"] = GameData.base_item_data[new_item["item_id"]]["Type"]
	for i in GameData.item_stats:
		if GameData.base_item_data[new_item["item_id"]][i] != null:
			new_item[i] = ItemDetermineStats(new_item["item_id"], new_item["item_rarity"], i)
	new_item = RandomizeStats(new_item)
	var item_rarity_id = ItemDetermineUniqueId(new_item)
	new_item.erase("item_id")
	new_item_dict[item_rarity_id] = new_item
	return new_item_dict

func ItemDetermineType(type: String = "", slot: String = "") -> String:
	var new_item_type: String
	var item_types: Array = GameData.base_item_data.keys()
	if type == "" and slot == "":
		new_item_type = item_types[randi() % item_types.size()]
		return new_item_type
	elif slot != "":#slot specified
		var specified_item_slot: Array = []
		for i in GameData.base_item_data.keys():
			if GameData.base_item_data[i]["equipmentSlot"] == slot:
				specified_item_slot.append(i)
		new_item_type = specified_item_slot[randi() % specified_item_slot.size()]
		return new_item_type
	else:#type specified, slot not specified
		var specified_item_type: Array = []
		for i in GameData.base_item_data.keys():
			if GameData.base_item_data[i]["Type"] == type:
				specified_item_type.append(i)
		new_item_type = specified_item_type[randi() % specified_item_type.size()]
		return new_item_type

func ItemDetermineRarity(rarity: String = "") -> String:
	if rarity != "":
		return rarity
	var new_item_rarity: String
	var item_rarities: Array = GameData.item_rarity_ditribution.keys()
	var rarity_roll: float = randf_range(0.0, 100)
	for i in item_rarities:
		if rarity_roll <= GameData.item_rarity_ditribution[i]:
			new_item_rarity = i
			break
		else:
			rarity_roll -=GameData.item_rarity_ditribution[i]
	return new_item_rarity

func RandomizeStats(item: Dictionary) -> Dictionary:
	var result: Dictionary = item
	var minimum_stats = 0
	var item_stats = []
	if(item["Type"] == "Weapon"):
		for i in GameData.weapon_randomized_stats:
			if item[i] != 0:
				item_stats.append(i)
	elif item["item_rarity"] == "common":
		for i in GameData.common_randomized_stats:
			if item[i] != 0:
				item_stats.append(i)
		item["Strength"] = 0
		item["Speed"] = 0
	else:
		for i in GameData.item_randomized_stats:
			if item[i] != 0:
				item_stats.append(i)
	
	var total_number_of_stats = item_stats.size()
	if(item["item_rarity"] == "common"): minimum_stats = 1
	if(item["item_rarity"] == "uncommon"): minimum_stats = randi_range(1,2)
	if(item["item_rarity"] == "rare"): minimum_stats = randi_range(2,3)
	if(item["item_rarity"] == "epic"): minimum_stats = randi_range(4,5)
	if(item["item_rarity"] == "legendary"): minimum_stats = randi_range(5,6)
	if(item["Type"] == "Weapon"): 
			minimum_stats -= 1
	while(total_number_of_stats > minimum_stats):
		var random_stat = item_stats[randi_range(0, item_stats.size()-1)]
		total_number_of_stats -= 1
		item[random_stat] = 0
		item_stats.erase(random_stat)
	return result

func ItemDetermineStats(item_id, item_rarity, stat) -> float:
	var stat_value: int
	if GameData.base_item_data[item_id]["Type"] == "Jewelry" and stat == "Accuracy":
		stat_value = randi_range(2,6) * int(GameData.base_item_data[item_id][stat])
	elif GameData.item_mitigation_stats.has(stat):
		stat_value = randi_range(2,6) * int(GameData.base_item_data[item_id][stat])
	elif GameData.item_attribute_stats.has(stat):
		stat_value = randi_range(1,2) * int(GameData.base_item_data[item_id][stat])
	elif GameData.item_damage_stats.has(stat):
		stat_value = (ceili(randf_range(0.8, 1.2) * GameData.base_item_data[item_id][stat])) * GameData.base_item_data[item_id][item_rarity + "Multi"]
	else:
		stat_value = GameData.base_item_data[item_id][stat]
	return stat_value

func ItemDetermineUniqueId(item :Dictionary) -> int:
	var new_item_type_int = int(item["item_id"])
	var item_rarities: Array = GameData.item_rarity_ditribution.keys()
	if(item["item_rarity"] != "common"):
		for i in item_rarities:
			new_item_type_int += 1000
			if item["item_rarity"] == i:
				break
	while(GameData.item_data.has(new_item_type_int)):
		new_item_type_int += 1
	return new_item_type_int

func ItemDetermineName(base_item_id: String, rarity: String) -> String:
	var item_name: String
	item_name =  str(GameData.base_item_data[base_item_id]["name"]) + "_" + rarity
	return item_name
