extends AnimationPlayer
@export var album: Album


# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignals.camera_change.connect(on_camera_change)
	GlobalSignals.picture_taken.connect(on_camera_change)
	pass # Replace with function body.


func on_camera_change(is_out):
	if is_out && !album.album.has(get_parent()):
		play("dance")
	if !is_out || album.album.has(get_parent()):
		stop()
