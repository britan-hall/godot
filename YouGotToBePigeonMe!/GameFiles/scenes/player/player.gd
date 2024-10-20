extends CharacterBody2D
signal hit
signal eat(is_moving:bool)
signal throw(player_pos, throw_pos)
signal camera_out(is_camera_out:bool)
signal camera_taking

var speed
var dir_facing
var screen_size
var is_camera_out
var throw_distance
var is_invincible: bool = false
var disable_player_control: bool = false
var is_dashing: bool = false
var can_dash: bool = true
var game_over = false
@onready var i_frames_timer: Timer = $InvincibilityTimer
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var base_speed: int = 100
@export var moving = false
@export var starting_throw_distance = 5
@export var throw_grow_distance = 5
@export var enemies: Node
@export var dash_velocity_multiplier: float = 3
@export var player_stats: PlayerStats
@export var hit_cost = 5
@export var crumb_cost = 2

@export var photo_cooldown = 1
var current_photo_cooldown = photo_cooldown


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	sprite.play("looking_down")
	throw_distance = starting_throw_distance
	is_camera_out = false
	speed = base_speed
	dir_facing = Vector2.DOWN
	game_over = false
	
	player_stats.player_pos = position
	player_stats.lunch_eaten = 0
	player_stats.lunch_remaining = player_stats.start_lunch_value
	$EatProgressBar.value = 0
	
	GlobalSignals.player_hit.connect(on_player_hit)
	
	# Dummy eat setup
	GlobalSignals.stats_updated.connect(on_stats_updated)
	GlobalSignals.stats_updated.emit()
	
	# Game over behaviour setup
	GlobalSignals.game_over.connect(on_game_over)
	disable_player_control = false
	
	# enable collision
	$CollisionShape2D.set_deferred("disabled", false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	#var velocity = Vector2.ZERO
	#if Input.is_action_pressed("move_up"):
		#velocity.y -= 1
	#if Input.is_action_pressed("move_down"):
		#velocity.y += 1
	#if Input.is_action_pressed("move_right"):
		#velocity.x += 1
	#if Input.is_action_pressed("move_left"):
		#velocity.x -= 1
		#
	if direction.length() > 0:
		#velocity = velocity.normalized() * speed
		dir_facing = direction
		moving = true
	else:
		moving = false
	#position += velocity * delta
	#position = position.clamp(Vector2.ZERO, screen_size)
		
	
	if Input.is_action_pressed("throw"):
		throw_distance += throw_grow_distance
	if Input.is_action_just_released("throw") && !game_over:
		player_stats.lunch_remaining -= crumb_cost
		var throw_pos = global_position + (dir_facing * throw_distance)
		throw.emit(global_position, throw_pos)
		throw_distance = starting_throw_distance
	
	if Input.is_action_just_pressed("eat"):
		#TODO: this is a dummy implementation
		# JULIUS replace this with your minigame
		#eat.emit(moving)
		pass
	if Input.is_action_pressed("eat"):
		can_dash = false
		var hold_time: float = 2
		var eat_value = 10
		velocity = Vector2.ZERO
		# keep track of hold time
		if not game_over:
			$EatProgressBar.value += delta * (100.0/hold_time)
		if $EatProgressBar.value >= 100:
			$EatProgressBar.value = 0
			# only eat if you still have lunch
			if player_stats.lunch_remaining > 0:
				# make sure 
				var eaten = min(player_stats.lunch_remaining, eat_value)
				player_stats.lunch_eaten += eaten
				player_stats.lunch_remaining -= eaten
	if Input.is_action_just_released("eat"):
		$EatProgressBar.value = 0
		can_dash = true
	
	if Input.is_action_just_pressed("ready_camera") && !game_over:
		is_camera_out = !is_camera_out
		#yeah i might remove the next line but currently theyre for different things
		# camera/picture taker
		camera_out.emit(is_camera_out)
		# enemies dance
		GlobalSignals.camera_change.emit(is_camera_out)
		
	current_photo_cooldown += delta
	if Input.is_action_just_pressed("take_photo"):
		if is_camera_out && current_photo_cooldown > photo_cooldown:
			current_photo_cooldown = 0
			camera_taking.emit()
			GlobalSignals.picture_taken.emit(true)
	
	if Input.is_action_just_pressed("dash") and can_dash and not game_over:
		dash()
	
	if is_dashing:
		velocity = dir_facing * speed * dash_velocity_multiplier
	
	if disable_player_control:
		velocity = Vector2.ZERO
		
	if velocity.length() == 0:
		if dir_facing.y < 0:
			sprite.play("looking_up")
		if dir_facing.y > 0:
			sprite.play("looking_down")
		if dir_facing.x < 0:
			sprite.play("looking_left")
		if dir_facing.x > 0:
			sprite.play("looking_right")
	else:
		if dir_facing.y < 0 && dir_facing.x == 0:
			sprite.play("walking_up")
		if dir_facing.y > 0 && dir_facing.x == 0:
			sprite.play("walking_down")
		if dir_facing.x < 0:
			sprite.play("walking_left")
		if dir_facing.x > 0:
			sprite.play("walking_right")
		
	
	var _collision = move_and_slide()
	# Set the player pos in stats resource to be accessed by other nodes
	player_stats.player_facing = dir_facing
	player_stats.player_pos = position


func on_player_hit(body):
	if not is_invincible:
		#print("ouch!!! hit by " + body.name)
		player_stats.lunch_remaining -= hit_cost
		$EatProgressBar.value = 0
		i_frames_timer.start()
		
		if "play_attack_sound" in body:
			body.play_attack_sound()

func on_stats_updated():
	#$LunchProgressBar.value = player_stats.lunch_remaining
	pass

func _on_body_entered(_body):
	#hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)


func _on_lunch_eating_speed_percentage(percent):
	speed = base_speed * percent/100
	
func on_game_over():
	disable_player_control = true
	$CollisionShape2D.set_deferred("disabled", true)
	game_over = true
	is_camera_out = false
	camera_out.emit(false)
	

func dash():
	is_dashing = true
	can_dash = false
	anim_player.play("dash")

func finish_dash():
	is_dashing = false
	$DashCooldownTimer.start(player_stats.dash_recharge_time)

func set_invincible(value: bool):
	is_invincible = value

func _on_invincibility_timer_timeout():
	is_invincible = false
	
func _on_dash_cooldown_timer_timeout():
	can_dash = true
	GlobalSignals.dash_recharged.emit()
