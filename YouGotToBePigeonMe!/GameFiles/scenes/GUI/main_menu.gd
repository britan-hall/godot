extends Control

@onready var animator: AnimationPlayer = $AnimationPlayer



# Called when the node enters the scene tree for the first time.
func _ready():
	animator.play("start_screen")
	$VBoxContainer/StartButton.grab_focus()
