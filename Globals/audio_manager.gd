extends Node

@onready var music: AudioStreamPlayer = null
var current_song: String = ""
var precombat_song: String = ""

func _ready() -> void:
	music = get_node("untitled")
	music.playing = true
	current_song = "untitled"
	precombat_song = "untitled"

func _process(_delta: float) -> void:
	if music.playing == false and GameState.state == "":
		music.playing = true

### REVIEW LATER: unused hook for per-area music (e.g. a different track for caves).
### Only one exploration track exists so far (the "untitled" node plays exploration.wav).
func change_precombat_song(song: String):
	get_node(current_song).playing = false
	music = get_node(song)
	music.playing = true
	current_song = song
	precombat_song = song

func change_song_to_combat(song: String):
	get_node(current_song).playing = false
	music = get_node(song)
	music.playing = true
	current_song = song

func change_to_precombat_song():
	get_node(current_song).playing = false
	music = get_node(precombat_song)
	music.playing = true
	current_song = precombat_song

func pause():
	get_node(current_song).playing = false

### REVIEW LATER: unused partner of pause(); returning from combat uses
### change_to_precombat_song(), and _process() restarts stopped music outside combat.
func resume():
	get_node(current_song).playing = true

func level_change():
	get_node("level_change").playing = true
