extends Control

var template_inv_slot = preload("res://Scenes/Templates/inventory_slot.tscn")

@onready var grid_ref = $MarginContainer/Inventory_Grid

func _ready() -> void:
	SignalBus.connect("item_collected", Callable(self, "_pull_inventory_data"))

	_init_inventory()

func _init_inventory():
	for i in PlayerData.inv_data.keys():
		var inv_slot_new = template_inv_slot.instantiate()
		if PlayerData.inv_data[i]["Item"] != 0 and GameData.item_data.has(PlayerData.inv_data[i]["Item"]):
			var item_name = GameData.item_data[PlayerData.inv_data[i]["Item"]]["item_name"]
			var icon_texture = load("res://Assets/item_assets/"+ item_name +".png")
			inv_slot_new.get_node("Icon").set_texture(icon_texture)
		grid_ref.add_child(inv_slot_new, true)

func _pull_inventory_data():
	for n in grid_ref.get_children():
		n.free()
	_init_inventory()
