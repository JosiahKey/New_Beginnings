extends Node

var item_data = {
	66666: { "item_rarity": "legendary", 
	"item_name": "sword_legendary", 
	"equipmentSlot": "Mainhand", 
	"Type": "Weapon", 
	"Damage_min": 100.0, 
	"Damage_max": 200.0, 
	"Accuracy": 100.0, 
	"Evasion": 0, 
	"Hp": 0, 
	"PDR": 20, 
	"Strength": 0, 
	"Speed": 0.0 
	}
}
var base_item_data = {}

var item_stats = ["Damage_min", "Damage_max", "Accuracy", "Evasion", "Hp", "PDR", "Strength", "Speed"] #Weight
var item_stats_readable = ["Minimum Damage", "Maximum Damage", "Hit Chance", "Evasion", "Hp", "Armor", "Strength", "Speed"] #"Weight"
var item_mitigation_stats = ["Evasion", "PDR"]
var item_attribute_stats = ["Strength", "Speed"]
var item_damage_stats = ["Damage_min", "Damage_max", "Hp"]
var item_randomized_stats = ["Damage_min", "Damage_max", "Accuracy", "Evasion", "Hp", "PDR", "Strength", "Speed"]
var weapon_randomized_stats = ["Evasion", "PDR", "Strength", "Speed"]
var common_randomized_stats = ["Damage_min", "Damage_max", "Evasion", "PDR", "Hp"]

var item_rarity_ditribution = {"common": 65.0,
	"uncommon": 28.0,
	"rare": 5.0,
	"epic": 1.8,
	"legendary": 0.2}


var enemy_data = {}
#example entry, loaded from Data/enemy_data.json in _ready()
#	"10001": {
#	"enemy_name": "green_slime",
#	"Max_hp": 120,
#	"Current_hp": 120,
#	"Damage_min": 20,
#	"Damage_max": 30,
#	"Accuracy": 90,
#	"Evasion": 5,
#	"PDR": 0,
#	"Speed": 3,
#	"EXP": 300,
#	"Loot": 1
#	},

var biome_data = {}

func _ready() -> void:
	var item_data_file = FileAccess.open("res://Data/items_data.json", FileAccess.READ)
	var item_data_json = JSON.parse_string(item_data_file.get_as_text())
	item_data_file.close()
	base_item_data = item_data_json
	var enemy_data_file = FileAccess.open("res://Data/enemy_data.json", FileAccess.READ)
	var enemy_data_json = JSON.parse_string(enemy_data_file.get_as_text())
	enemy_data_file.close()
	enemy_data = enemy_data_json
	var biome_data_file = FileAccess.open("res://Data/biome_data.json", FileAccess.READ)
	var biome_data_json = JSON.parse_string(biome_data_file.get_as_text())
	biome_data_file.close()
	biome_data = biome_data_json

func pick_random_enemy() -> Dictionary:
	var result: Dictionary = {}
	var enemies_in_biome: Array = []
	for biome in biome_data:
		if biome == GameState.biome:
			for enemies in biome_data[biome]:
				if(biome_data[biome][enemies] != 0):
					enemies_in_biome.append(enemies)
	var random_enemy_index: int = 0
	random_enemy_index = randi_range(0, enemies_in_biome.size()-1)
	var enemy_name = enemies_in_biome[random_enemy_index]
	for f in enemy_data:
		if enemy_data[f]["enemy_name"] == enemy_name:
			result = enemy_data[f]
	print(enemy_name)
	return result

func get_readable_enemy_info(enemy: Dictionary) -> String:
	var output_string = enemy["enemy_name"] + "
	HP: " + str(int(enemy["Current_hp"])) + "
	Damage: " + str(int(enemy["Damage_min"])) + "-" + str(int(enemy["Damage_max"])) + "
	Hit Chance: " + str(int(enemy["Accuracy"])) + "%
	Evade Chance: " + str(int(enemy["Evasion"])) + "%
	Armor: " + str(int(enemy["PDR"])) + "
	Speed: " + str(int(enemy["Speed"]))
	return output_string
