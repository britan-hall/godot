extends Label

var time: float = 0
var rotate_right: bool = true
@export var rotate_time: float
@export var rotate_amount_deg: int
@export var start_rotate_offset_deg: int

# Called when the node enters the scene tree for the first time.
func _ready():
	pivot_offset = size / 2
	rotation_degrees += start_rotate_offset_deg


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if time > rotate_time:
		if rotate_right:
			rotation_degrees += rotate_amount_deg
		else:
			rotation_degrees -= rotate_amount_deg
		rotate_right = !rotate_right
		time = 0
