@tool

#extends Area2D
extends CharacterBody2D

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var hop_timer: Timer = $HopTimer
@onready var sprite: Sprite2D = $PigeonImage
@onready var orienter: Node


@export var player_stats: Resource
# how fast the pigeon hops from one point to another
@export var hop_travel_speed: float = 0.2
# Min and max time between each hop
@export var min_hop_interval: float = 0.5
@export var max_hop_interval: float = 1
# Max distance of each hop in global units
@export var max_hop_distance: float = 20
# amount pigeons scatter a bit when choosing where to hop
@export var pos_variance: int = 10
# if player is within this radius, pigeon will follow. otherwise, hop randomly
@export var detect_player_radius: int = 200

var target_reached = false


func _ready():
	if not Engine.is_editor_hint():
		call_deferred("navigation_setup")
		orienter = get_node("SpriteOrienter")
		GlobalSignals.game_over.connect(on_game_over)

func navigation_setup():
	# you need this line to wait for NavigationServer2D to sync (first physics frame)
	await get_tree().physics_frame
	nav_agent.path_desired_distance = max_hop_distance
	hop_timer.start(randf() * max_hop_interval)
	
# use pathfinding to get where pigeon should hop next towards player
func get_next_pos():
	# so glad i found this line early on i knew something like this was here but like wtf is this youve already set it
	#nav_agent.target_position = player_stats.player_pos
	
#region Alternate pathfinding with set max distance
# this code will move the pigeon in the general direction in a definable distance
# instead of just relying on godot's A* algo to generate points
# use this code instead if you want to control the hop distance precisely
# however, it also lets pigeons go where they shouldn't (in collidable places)
	#var direction = (nav_agent.get_next_path_position() - player_stats.player_pos).normalized() * max_hop_distance
	#return (position - direction)
#endregion
	# add some variation to final position
	var target = nav_agent.get_next_path_position()
	target.x += randf_range(-1, 1) * pos_variance
	target.y += randf_range(-1, 1) * pos_variance
	return target
	

func _on_navigation_agent_2d_navigation_finished():
	target_reached = true
	#print("pigeon reached player")

# make the pigeon hop towards player on random time intervals
# or crumbs
func _on_timer_timeout():
	
	if not Engine.is_editor_hint():
		
		nav_agent.target_position = player_stats.player_pos
		
		# search for closest player / crumb
		var min_target = player_stats.player_pos
		var min_target_dist = nav_agent.distance_to_target()
		for crumbs in get_tree().get_nodes_in_group("crumbs"):
			nav_agent.target_position = crumbs.position
			if min_target_dist > nav_agent.distance_to_target():
				min_target = crumbs.position
				min_target_dist = nav_agent.distance_to_target()
		
		nav_agent.target_position = min_target
		
		#print(nav_agent.distance_to_target())
		if nav_agent.distance_to_target() > detect_player_radius:
			# hop randomly if player out of detection radius
			hop_random_direction()
		else:
			# actually hop towards player
			var target_pos = get_next_pos()
			var tween = get_tree().create_tween()
			# move pigeon to new pos
			tween.tween_property($".", "position", target_pos, hop_travel_speed)
			
			# hop animation
			$AnimationPlayer.play("bird_hop")
			orienter.face_direction(position.x, target_pos.x, sprite)
			
			# restart hop timer to random time
			hop_timer.start(randf_range(min_hop_interval, max_hop_interval))

# copy pasted from seagull hehe
func hop_random_direction():
	# get random distance and angle
	var hop_dist = randf() * max_hop_distance
	var angle = randf() * 2 * PI
	var target_pos = Vector2(position.x, position.y)
	target_pos.x += hop_dist * cos(angle)
	target_pos.y += hop_dist * sin(angle)
	
	# move seagull to this point
	$AnimationPlayer.play("bird_hop")
	var tween = get_tree().create_tween()
	tween.tween_property($".", "position", target_pos, hop_travel_speed).set_trans(Tween.TRANS_QUAD)
	orienter.face_direction(position.x, target_pos.x, sprite)
	
	# restart hop timer
	hop_timer.start(randf_range(min_hop_interval, max_hop_interval))

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if get_node("SpriteOrienter") == null:
		warnings.append("Entity requires a SpriteOrienter scene component")
	if get_node("EnemyHitboxComponent") == null:
		warnings.append("Entity requires a EnemyHitboxComponent")
	return warnings

func on_game_over():
	# make it so pigeons ignore player after lunch is finished
	detect_player_radius = 0

# This is to prevent sfx from being cut off when the next one needs to be played
func play_attack_sound():
	var audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	add_child(audio)
	audio.stream = load("res://audio/pigeon_flap.mp3")
	audio.play(	)
	await audio.finished
	audio.queue_free()
