extends MarginContainer

@onready var item_icon := $TextureRect
@onready var item_label := $Label
var item_id

func set_readable_label(nam):
	item_label.text = nam

func set_icon(ico):
	item_icon.texture = ico

func set_item_id(id):
	item_id = id

func _on_pressed() -> void:
	for i in PlayerData.inv_data.keys():
			if PlayerData.inv_data[i]["Item"] == 0:
				PlayerData.inv_data[i]["Item"] = item_id
				SignalBus.item_collected.emit()
				break
	self.queue_free()
