extends CanvasLayer

func _ready() -> void:
	SignalBus.connect('combat_entered', Callable(self, "enter_combat"))

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

### REVIEW LATER: fade when leaving combat. Disconnected on 2026-01-19 when
### combat_exited was pointed at combat_engine.clean_up() instead.
### To re-enable: uncomment, and connect combat_exited to it in _ready().
#func exit_combat():
#	self.visible = true
#	get_tree().paused = true
#	$TextureRect.visible = false
#	$AnimationPlayer.play('fadeout')
#	await $AnimationPlayer.animation_finished
#	$AnimationPlayer.play_backwards('fadeout')
#	await $AnimationPlayer.animation_finished
#	self.visible = false
#	get_tree().paused = false
#	$TextureRect.visible = true
#	SignalBus.scene_transition_finished.emit()
