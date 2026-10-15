extends Area2D

@export var randomizes: bool = false
@export var world_map: bool = false

func _on_next_level_entered(body):
	if body.is_in_group("Player"):
		AudioManager.level_change()
		if randomizes:
			SignalBus.load_area_entered.emit()
		elif world_map:
			SignalBus.world_map_entered.emit()

func disable():
	$CollisionShape2D/StaticBody2D.queue_free()
