extends Node2D

@export var stats: PlayerStats
@export var music: AudioStreamPlayer
@export var game_over_audio: AudioStreamPlayer
var game_over = false

signal show_game_over_screen

# Called when the node enters the scene tree for the first time.
func _ready():
	# show all default values for UI
	GlobalSignals.stats_updated.emit()
	GlobalSignals.game_over.connect(on_game_over)
	#music.play()


func _process(delta):
	if not game_over:
		stats.total_time += delta

func on_game_over():
	game_over = true
	music.stop()
	game_over_audio.play()
	await get_tree().create_timer(2).timeout
	show_game_over_screen.emit()

func _on_tutorial_screen_game_started():
	music.play()
