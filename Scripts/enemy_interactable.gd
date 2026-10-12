extends Area2D
### REVIEW LATER: Home.tscn has a debug copy of this boss trigger. Remove it once the
### caves have a real boss (after the overworld/Bossarea is deleted it's the only way
### to reach the boss). Don't add a debug-build check here; the real boss uses this script too.

func _on_next_level_entered(body):
	if body.is_in_group("Player"):
		SignalBus.player_paused.emit()
		AudioManager.change_song_to_combat("boss")
		SignalBus.combat_entered.emit()
		await get_tree().create_timer(0.5).timeout
		GameState.biome = "Boss"
		SignalBus.enemy_encountered.emit()
		queue_free()
