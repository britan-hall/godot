@tool

extends CharacterBody2D

var fallen_over: bool = false
@export var speed: int = 150
@export var fall_over_interval: float = 7
@export var fall_over_variance: float = 2
@export var slide_time: float = 2
# the value multiplied to gradually slow down child movement
# 1 is normal speed, 0 is full stop
var curr_slide: float = 1
var slide_elapsed: float = 0

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready():
	if not Engine.is_editor_hint():
		# choose random starting direction
		var angle = randf_range(0, 2 * PI)
		velocity = Vector2(sin(angle), cos(angle)).normalized()
		$FallOverTimer.start(randf_range(fall_over_interval - fall_over_variance, fall_over_interval + fall_over_variance))


func _physics_process(delta):
	if not Engine.is_editor_hint():
		# if child falls over, curr_slide
		if fallen_over:
			# make sure elapsed time does not go over duration
			slide_elapsed = min(slide_elapsed + delta, slide_time)
			curr_slide = Tween.interpolate_value(1.0, -1.0, slide_elapsed, slide_time, Tween.TRANS_EXPO, Tween.EASE_OUT)
			#print("elapsed: " + str(slide_elapsed) + " | lerp: " + str(curr_slide))
			
		var collision_info = move_and_collide(speed * velocity * delta * curr_slide)
		
		if collision_info:
			velocity = velocity.bounce(collision_info.get_normal())


func _on_area_2d_body_entered(body):
	print(str(body.name) + " entered child enemy")


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if get_node("SpriteOrienter") == null:
		warnings.append("Entity requires a SpriteOrienter scene component")
	if get_node("EnemyHitboxComponent") == null:
		warnings.append("Entity requires a EnemyHitboxComponent")
	return warnings


func _on_fall_over_timer_timeout():
	fallen_over = true
	anim.play("fall_over")
	
# called in the fall_over animation
func resume_running():
	fallen_over = false
	slide_elapsed = 0
	curr_slide = 1
	# choose random direction and next fall over time
	var angle = randf_range(0, 2 * PI)
	velocity = Vector2(sin(angle), cos(angle)).normalized()
	$FallOverTimer.start(randf_range(fall_over_interval - fall_over_variance, fall_over_interval + fall_over_variance))

func play_attack_sound():
	$AudioStreamPlayer2D.play()
