extends Label

@export var stats : PlayerStats

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignals.stats_updated.connect(on_stats_updated)


func on_stats_updated():
	text = str(stats.lunch_eaten) + "%"
