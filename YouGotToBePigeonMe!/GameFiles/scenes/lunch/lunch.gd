extends Node2D
@export var eat_rate = 1
@export var eat_percent = 0	
@export_enum("Wrap", "Fork", "Chopsticks", "Soup") var food_type: int
@export var wrap_move_percentage = 50
signal eating_speed_percentage(percent:int)
signal launch_microgame(game)
signal food_complete
var eating:bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if eating:
		eat_percent += eat_rate * delta
		if eat_percent == 100:
			food_complete.emit()
	

func _on_player_eat(is_moving:bool):
	print(eat_percent)
	if eating:
		eating = false
		eating_speed_percentage.emit(100)
	elif food_type == 0:
		eating = true
		eating_speed_percentage.emit(wrap_move_percentage)
	elif !is_moving:
		eating = true
		eating_speed_percentage.emit(0)
		
		
		

