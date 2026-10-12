extends Area2D

@onready var mark: Marker2D = $Destination
@onready var player = $"../../Player" #this is very bad, this should be a signal
									  #hopefully it is only ever used here tho for the tower

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player.global_position = mark.global_position
