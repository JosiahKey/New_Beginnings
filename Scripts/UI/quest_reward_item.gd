extends MarginContainer
### REVIEW LATER: lines below (up to get_item_id) are duplicated in reward_item.gd

@onready var item_icon := $TextureRect
@onready var item_label := $Label
var item_id

func set_readable_label(nam):
	item_label.text = nam

func set_icon(ico):
	item_icon.texture = ico

func set_item_id(id):
	item_id = id

func get_item_id() -> int:
	return item_id
