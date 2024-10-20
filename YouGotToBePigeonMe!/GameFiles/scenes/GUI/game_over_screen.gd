extends CanvasLayer

@export var grade_sprite: Sprite2D
@export var stats: PlayerStats
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var time_label = $MarginContainer/HBoxContainer/StatsContainer/TimeLabel
@onready var eaten_label = $MarginContainer/HBoxContainer/StatsContainer/EatenLabel
@onready var pidgeon_label = $MarginContainer/HBoxContainer/StatsContainer/PidgeonLabel
@onready var seagull_label = $MarginContainer/HBoxContainer/StatsContainer/SeagullLabel
@onready var child_label = $MarginContainer/HBoxContainer/StatsContainer/ChildLabel
@export var album: Album

@onready var shuffle_noise = $Audio/shuffle_grade
@onready var show_noise = $Audio/show_grade

var shuffle_frequency: float = 0.1
@onready var time_text = time_label.text
@onready var eaten_text = eaten_label.text
var time = 0.0
var refresh = 0.0

var first_time_called : bool = true

# dictionary of threshholds for each grade
var grades = {
	"S": 95,
	"A": 80,
	"B": 70,
	"C": 60,
	"D": 50
}

# Called when the node enters the scene tree for the first time.
func _ready():
	#visible = false
	time_text = time_label.text
	eaten_text = eaten_label.text
	time_label.text += "----"
	eaten_label.text += "----"
	grade_sprite.visible = false
	
	pidgeon_label.visible = false
	seagull_label.visible = false
	child_label.visible = false
	
	
	

func show_letter_grade():
	# this works only for the specific sprite sheet i found
	# update later when revamping graphics
	var eaten = stats.lunch_eaten
	if eaten >= grades.S:
		grade_sprite.frame = 0
	elif eaten >= grades.A:
		grade_sprite.frame = 1
	elif eaten >= grades.B:
		grade_sprite.frame = 3
	elif eaten >= grades.C:
		grade_sprite.frame = 5
	elif eaten >= grades.D:
		grade_sprite.frame = 6
	else:
		grade_sprite.frame = 8

func rand_nums() -> float:
	return randf_range(0, 500)
	

func _on_level_base_show_game_over_screen():
	#for some reason this can be called twice (geogi neo I fancy you amuna wonhaji anh-a) so this stops that
	if !first_time_called:
		return
	else:
		first_time_called = false
		
	var pidgeon_count = 0
	var seagull_count = 0
	var child_count = 0
	for bird in album.album.keys():
		print(bird.name.substr(0,3))
		if bird.name.substr(0,3) == "Pig": #cant believe i have to admit im naming them wrong
			pidgeon_count += 1
		if bird.name.substr(0,3) == "Sea":
			seagull_count += 1
		if bird.name.substr(0,3) == "Chi":
			child_count += 1
	pidgeon_label.text += str(pidgeon_count)
	seagull_label.text += str(seagull_count)
	child_label.text += str(child_count)
	
	visible = true
	# shuffle through random nums for time
	for i in range(20):
		shuffle_noise.play()
		time_label.text = time_text + ("%.2f" % rand_nums()) + "s"
		await get_tree().create_timer(0.05).timeout
	show_noise.play()
	time_label.text = time_text + ("%.2f" % stats.total_time) + "s"
	# shuffle through random nums for score
	for i in range(20):
		shuffle_noise.play()
		eaten_label.text = eaten_text + str("%.f" %rand_nums()) + "%"
		await get_tree().create_timer(0.05).timeout
	show_noise.play()
	eaten_label.text = eaten_text + str("%.f" %stats.lunch_eaten) + "%"

	# play animation for final grade
	grade_sprite.visible = true
	anim.play("show_grade")
	await get_tree().create_timer(1).timeout
	if stats.lunch_eaten >= grades["S"]:
		$Audio/YIPPEE.play(0.5)
	pidgeon_label.visible = true
	await get_tree().create_timer(0.3).timeout
	seagull_label.visible = true
	#i may alter this later to count times a child has been photoed for a score penalty
	#await get_tree().create_timer(0.3).timeout
	#child_label.visible = true
