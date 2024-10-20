extends VBoxContainer

@export var stats : PlayerStats

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignals.stats_updated.connect(on_stats_updated)

func on_stats_updated():
	$RedCircleUnderlay/RemainingUnderlay.value = stats.lunch_remaining + stats.lunch_eaten
	$RedCircleUnderlay/EatenProgressBar.value = stats.lunch_eaten
