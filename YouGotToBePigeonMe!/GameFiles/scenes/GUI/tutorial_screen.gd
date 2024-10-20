extends CanvasLayer

var instruction_anim_finished = false
var intro_started = false
@onready var anim: AnimationPlayer = $AnimationPlayer

signal game_started

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true
	anim.play("move_into_screen")
	$CrossingSignal.visible = false
	
func on_instruction_anim_finished():
	instruction_anim_finished = true
	$"any key".visible = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if instruction_anim_finished and Input.is_anything_pressed() and not intro_started:	
		$instructions.visible = false
		$"any key".visible = false
		$tutorial.visible = false
		$dim.visible = false
		anim.play("intro")
		intro_started = true

func emit_game_start():
	game_started.emit()
	get_tree().paused = false
