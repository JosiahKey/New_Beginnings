extends NinePatchRect

@onready var  max_hp_label = $M/V/Stat_Grid/Health_Points_Bar/stat_num
@onready var  acc_label = $M/V/Stat_Grid/Accuracy_Stat_Label/stat_num
@onready var  eva_label = $M/V/Stat_Grid/Evasion_Stat_Label/stat_num
@onready var  pdr_label = $M/V/Stat_Grid/PDR_Stat_Label/stat_num
@onready var  spd_label = $M/V/Stat_Grid/Speed_Stat_Label/stat_num
@onready var  stren_label = $M/V/Stat_Grid/Strength_Stat_Label/stat_num
@onready var  dmg_label = $M/V/Stat_Grid/Damage_Stat_Label/stat_num
@onready var  weight_label = $M/V/Stat_Grid/Weight_Stat_Label/stat_num
@onready var  exp_bar = $M/V/H/Exp_Bar
@onready var  exp_bar_label = $M/V/H/Exp_Bar/exp_bar_label
@onready var  hp_bar = $M/V/Stat_Grid/Health_Points_Bar
@onready var  lvl_label = $M/V/H/Level/Label

func _ready() -> void:
	SignalBus.connect("update_stat_panel", Callable(self, "_update_stat_panel"))
	_update_stat_panel()
	set_tooltips()

func _process(_delta: float) -> void:
	max_hp_label.text = str(int(PlayerData.stat_data["Current_hp"]))+ " / " + str(int(
		PlayerData.stat_data["Total_hp"]))
	hp_bar.value = PlayerData.stat_data["Current_hp"]

func _update_stat_panel():
	PlayerData.stat_data["Total_hp"] = PlayerData.stat_data["Natural_hp"] + PlayerData.stat_data["Bonus_hp"]
	acc_label.text = str(int(PlayerData.stat_data["Accuracy"])) + "%"
	eva_label.text = str(int(PlayerData.stat_data["Evasion"])) + "%"
	pdr_label.text = str(int(PlayerData.stat_data["PDR"])) + "%"
	stren_label.text = str(PlayerData.get_total_stength())
	spd_label.text = str(PlayerData.get_total_speed())
	max_hp_label.text = str(int(PlayerData.stat_data["Current_hp"])) + " / " + str(int(
		PlayerData.stat_data["Total_hp"]))
	dmg_label.text = str(int(PlayerData.stat_data["Total_equipped_damage_min"] + PlayerData.get_total_stength()*10)) + " - " + str(int(
						PlayerData.stat_data["Total_equipped_damage_max"]+ PlayerData.get_total_stength()*10))
	weight_label.text = str(int(PlayerData.stat_data["Total_equipped_weight"]))
	exp_bar_label.text = str(int(PlayerData.stat_data["Experience"])) + " / " + str(int(PlayerData.stat_data["Exp_to_next_level"]))
	exp_bar.max_value = PlayerData.stat_data["Exp_to_next_level"]
	exp_bar.value = PlayerData.stat_data["Experience"]
	hp_bar.max_value = PlayerData.stat_data["Total_hp"]
	hp_bar.value = PlayerData.stat_data["Current_hp"]
	lvl_label.text = str(PlayerData.stat_data["Level"])

func set_tooltips():
	$M/V/Stat_Grid/Health_Text/stat_label.tooltip_text = "Maximum HP\n When you reach 0 it's Game Over"
	$M/V/Stat_Grid/Accuracy_Text/stat_label.tooltip_text = "Chance To Hit an enemy when you attack\nNote: this does not account\nfor enemy evasion chance"
	$M/V/Stat_Grid/Evasion_Text/stat_label.tooltip_text = "Chance to Evade an enemy's attack"
	$M/V/Stat_Grid/PDR_Text/stat_label.tooltip_text = "Armor reduces all incoming\ndamage by this percentage"
	$M/V/Stat_Grid/Strength_Text/stat_label.tooltip_text = "Strength increases your minimum and\nmaximum damage by 10 per point"
	$M/V/Stat_Grid/Speed_Text/stat_label.tooltip_text = "Speed determines how many\ntimes you attack and which\ncombatant strikes first.\nYour Speed must be 4 higher\nthan your target to attack twice."
	### REVIEW LATER: Weight stat not implemented yet (also see equip_panel.gd)
	$M/V/Stat_Grid/Weight_Text/stat_label.tooltip_text = "NOT IMPLEMENTED YET\nit will restrict your speed\nand be mitigated by strength"
	$M/V/Stat_Grid/Damage_Text/stat_label.tooltip_text = "When you attack you will deal damage within this range"
	$M/V/H/Exp_Text/stat_label.tooltip_text = "Experience Points are needed to level\nup and gain additional stats"
