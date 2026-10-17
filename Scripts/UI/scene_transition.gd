extends CanvasLayer

func _ready() -> void:
	SignalBus.connect('enemy_encountered', Callable(self, "enter_combat"))

func enter_combat():
	#$SFX.playing = true  # REVIEW LATER: transition sound disabled
	self.visible = true
	get_tree().paused = true
	$AnimationPlayer.play('fadeout')
	await $AnimationPlayer.animation_finished
	$ColorRect.visible = false
	$AnimationPlayer.play('fadein')
	await $AnimationPlayer.animation_finished
	self.visible = false
	get_tree().paused = false
	$ColorRect.visible = true
	SignalBus.scene_transition_finished.emit()
