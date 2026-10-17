extends Node

var inv_data = {}

var active_player: String = "player1"

### REVIEW LATER: when building party combat, convert the combat code (combat_player,
### combat_engine, combat_ui, combat_reward, CombatData) to name the character
### explicitly instead of using the stat_data/equipment_data shortcuts below.
var players = {
	"player1": {
		"stat_data": {
			"Natural_hp": 200,
			"Bonus_hp": 0,
			"Total_hp": 0,
			"Current_hp": 200,
			"Strength": 1,
			"Bonus_strength": 0,
			"Speed": 1,
			"Bonus_speed": 0,
			"Accuracy": 0,
			"Evasion": 0,
			"PDR": 0,
			"Total_equipped_damage_min": 0,
			"Total_equipped_damage_max": 0,
			"Total_equipped_weight": 0,
			"Experience": 0,
			"Exp_to_next_level": 600,
			"Level": 1
		},
		"equipment_data": {
			"Head": 0,
			"Neck": 0,
			"Shoulders": 0,
			"Chest": 0,
			"Mainhand": 66666,
			"Offhand": 0,
			"Ring1": 0,
			"Arms": 0,
			"Waist": 0,
			"Legs": 0,
			"Feet": 0,
		},
	},
	"player2": {
		"stat_data" = {
			"Natural_hp": 200,
			"Bonus_hp": 0,
			"Total_hp": 0,
			"Current_hp": 200,
			"Strength": 99,
			"Bonus_strength": 0,
			"Speed": 1,
			"Bonus_speed": 0,
			"Accuracy": 0,
			"Evasion": 0,
			"PDR": 0,
			"Total_equipped_damage_min": 0,
			"Total_equipped_damage_max": 0,
			"Total_equipped_weight": 0,
			"Experience": 0,
			"Exp_to_next_level": 600,
			"Level": 1
		},
		"equipment_data" = {
			"Head": 0,
			"Neck": 0,
			"Shoulders": 0,
			"Chest": 0,
			"Mainhand": 66666,
			"Offhand": 0,
			"Ring1": 0,
			"Arms": 0,
			"Waist": 0,
			"Legs": 0,
			"Feet": 0,
		}
	}
}

var stat_data: Dictionary:
	get:
		return players[active_player]["stat_data"]
	set(value):
		players[active_player]["stat_data"] = value

var equipment_data: Dictionary:
	get:
		return players[active_player]["equipment_data"]
	set(value):
		players[active_player]["equipment_data"] = value

func _ready() -> void:
	_load_inv_data()
	stat_data["Total_hp"] = stat_data["Natural_hp"] + stat_data["Bonus_hp"]

func get_total_stength() -> int:
	var total = stat_data["Strength"] + stat_data["Bonus_strength"]
	return total

func get_total_speed() -> int:
	var total = stat_data["Speed"] + stat_data["Bonus_speed"]
	return total

func get_min_damage() -> int:
	return int(stat_data["Total_equipped_damage_min"] + get_total_stength()*10)

func get_max_damage() -> int:
	return int(stat_data["Total_equipped_damage_max"] + get_total_stength()*10)

func get_total_hp() -> int:
	return int(stat_data["Total_hp"])

func get_total_stat(stat:String) -> int:
	match stat:
		"Hp":
			return get_total_hp()
		"Strength":
			return get_total_stength()
		"Speed": 
			return get_total_speed()
		_:
			push_error("No stat of name: " + stat)
			return 0

func _load_inv_data():
	if not FileAccess.file_exists("user://inv_data.json"):
		var dir = DirAccess.open("user://")
		dir.copy("res://Data/inv_data.json", "user://inv_data.json")
		_load_inv_data()
	else:
		var inv_data_file = FileAccess.open("user://inv_data.json", FileAccess.READ)
		var inv_data_json = JSON.parse_string(inv_data_file.get_as_text())
		inv_data_file.close()
		inv_data = inv_data_json
		for k in inv_data.keys():
			inv_data[k]["Item"] = int(str(inv_data[k]["Item"]))

### REVIEW LATER: save system unfinished; this is never called. inv_data only holds
### item IDs. Item stats live in GameData.item_data, which isn't saved, so saving
### this alone would load "ghost" IDs next launch: slots look empty but stay
### occupied. A full save also needs item_data, equipment_data and stat_data.
func _save_inv_data():
	var inv_data_file = FileAccess.open("user://inv_data.json", FileAccess.WRITE)
	var inv_data_json = JSON.stringify(inv_data)
	inv_data_file.store_string(inv_data_json)
	inv_data_file.close()
