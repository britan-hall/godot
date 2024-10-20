extends ProgressBar

@export var stats: PlayerStats
@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	max_value = stats.dash_recharge_time
	value = max_value
	GlobalSignals.dash_recharged.connect(on_dash_recharged)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	value = stats.dash_recharge_time - timer.time_left
	if Input.is_action_just_pressed("dash") and value >= stats.dash_recharge_time:
		timer.start()

func on_dash_recharged():
	timer.stop()
	value = max_value
