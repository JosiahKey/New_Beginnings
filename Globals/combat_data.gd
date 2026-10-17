extends Node

var number_of_enemies = 0
var combatants_data: Dictionary = {
	"player1" : PlayerData.stat_data,
	"player2" : PlayerData.stat_data,
	#"enemy1" : data generated from enemy.gd init
}

var reward_data: Array = [0,0] #[exp, amount of loot]

func add_reward(experience: int, loot: int):
	reward_data[0] += experience
	reward_data[1] += loot

func add_combatant(new_combatant: Dictionary) -> String: #takes generate enemy as input
	number_of_enemies += 1
	var new_id: String = "enemy" + str(number_of_enemies)
	var new_dict: Dictionary = {new_id : new_combatant.duplicate()}
	combatants_data.merge(new_dict)
	return new_id

func clear_data():
	combatants_data = {"player" : PlayerData.stat_data,}
	number_of_enemies = 0
	reward_data = [0,0,0,0,0,0]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_combat_data"):
		print(JSON.stringify(combatants_data))
