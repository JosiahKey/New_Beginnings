extends Marker2D


@onready var label := $Label
var amount = 0
var type: String = ""

var velocity = Vector2(0,0)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	label.text = str(int(amount))
	var side_mov = randi() %81 -40
	velocity = Vector2(side_mov, 35)
	
	match type:
		"heal":
			label.add_theme_color_override("font_color", Color("2eff27"))
		"damage":
			label.add_theme_color_override("font_color", Color("ff3131"))
		"block":
			label.add_theme_color_override("font_color", Color("515151ff"))
			label.text = "Blocked " + str(int(amount))
			velocity = Vector2(0, -25)
		"evade":
			label.add_theme_color_override("font_color", Color("a9894aff"))
			label.text = str(amount)
		"miss":
			label.add_theme_color_override("font_color", Color("d5b2b6ff"))
			label.text = str(amount)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self,"scale", Vector2(1,1), 0.2)
	tween.tween_property(self,"scale", Vector2(0.1,0.1), 0.7)
	tween.tween_callback(self.queue_free)

func _process(delta: float) -> void:
	position -= velocity * delta
