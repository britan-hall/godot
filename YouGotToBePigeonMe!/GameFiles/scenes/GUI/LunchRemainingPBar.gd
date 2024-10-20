extends ProgressBar

@export var stats : PlayerStats

func _ready():
	GlobalSignals.stats_updated.connect(on_stats_updated)

func on_stats_updated():
	value = stats.lunch_remaining
