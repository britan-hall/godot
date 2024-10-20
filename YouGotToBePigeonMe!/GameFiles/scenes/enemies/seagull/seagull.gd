@tool

# The seagull locks onto the player if they get too close
# Then it flies to the player's last position in a straight line
# and overshoots a little to make it look natural
# Potential problems: 
#	- what if seagull overshoots and goes out of bounds?
#		- Make it respawn somewhere else out of camera view?

extends CharacterBody2D

@onready var sprite: Sprite2D = $SeagullImage
@onready var orienter: Node
@export var attack_travel_time: float = 2
@export var attack_extra_distance_percentage: float = 0.5
@export var player_stats: PlayerStats
@export var max_time_before_hop: int = 1
@export var max_hop_distance: int = 5
# how long it takes to hop from one point to another
var hop_time: float = 0.1
# to avoid seagull continuously locking on to player
var is_attacking: bool = false
var is_eating: bool = false
var targets = []


func _ready():
	if not Engine.is_editor_hint():
		$DetectArea.monitoring = true
		orienter = get_node("SpriteOrienter")
		GlobalSignals.game_over.connect(on_game_over)

# For a character body 2d
func _on_detect_area_body_entered(body):
	if body.name == "Player" and !is_attacking:
		$AnimationPlayer.play("detect")
		#await get_tree().create_timer(1).timeout
		is_attacking = true
		fly_towards_player()
	else:
		# TODO: debugging for now, delete later
		#print(str(body.name) + " has entered seagull range")
		pass

func _on_detect_area_body_exited(body):
	if body.name == "Player" and is_eating:
		is_attacking = false
		#distracted so loses sight

# If the player is an Area2D for some reason, copy paste code above down here
# Julius is using this for crumbs
func _on_detect_area_area_entered(area):
	if area.is_in_group("crumbs"):
		targets.push_back(area)
		if !is_eating:
			is_eating = true
			fly_towards_crumbs(area)
		else:
			targets.push_back(area)
		#should prioritise crumbs over the player crumbs already has a cost but maybe could speed up birds as well
	pass


func _on_detect_area_area_exited(area):
	targets.erase(area)
	pass # Replace with function body.


func fly_towards_player():
	var tween = get_tree().create_tween().set_parallel(false)
	tween.connect("finished", on_attack_finished)
	
	# Adding this will make the seagull fly <attack_extra_distance_percentage> more past the player
	var extra_flight = ((player_stats.player_pos - position) * attack_extra_distance_percentage)
	var target_pos = player_stats.player_pos + extra_flight
	
	# face correct direction
	orienter.face_direction(position.x, target_pos.x, sprite, false)
	
	# Make seagull fly to target pos with tween
	tween.tween_property($".", "position", target_pos, attack_travel_time).set_trans(Tween.TRANS_QUAD)

func fly_towards_crumbs(crumbs):
	# just copying the player part and hoping, should really learn this after demo done
	var tween = get_tree().create_tween().set_parallel(false)
	tween.connect("finished", on_eat_finished)
	
	
	# Adding this will make the seagull fly <attack_extra_distance_percentage> more past the player
	var extra_flight = ((crumbs.position - position) * attack_extra_distance_percentage)
	var target_pos = crumbs.position + extra_flight
	
	# face correct direction
	orienter.face_direction(position.x, target_pos.x, sprite, false)
	
	# Make seagull fly to target pos with tween
	tween.tween_property($".", "position", target_pos, attack_travel_time).set_trans(Tween.TRANS_QUAD)
	pass

func on_attack_finished():
	is_attacking = false
	
func on_eat_finished():
	await get_tree().create_timer(0.2).timeout
	while targets.size() != 0 && !is_instance_valid(targets[0]):
			targets.pop_front()
	if targets.size() != 0:
		fly_towards_crumbs(targets[0])
		
	if targets.size() == 0:
		is_eating = false;
		if is_attacking:
			fly_towards_player()
		
	pass

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
	tween.tween_property($".", "position", target_pos, hop_time).set_trans(Tween.TRANS_QUAD)
	orienter.face_direction(position.x, target_pos.x, sprite, false)
	
	# restart hop timer
	$HopTimer.start(randf() * max_time_before_hop)


# hop every time the timer runs out
func _on_hop_timer_timeout():
	if !is_attacking and !is_eating:
		hop_random_direction()

## face correct directions, assuming facing right is default
#func face_direction(curr_x_pos: float, target_x_pos: float, entity_sprite: Sprite2D, initial_facing_right: bool = true) -> void:
	## TODO: MAKE THIS INTO FUNCTION
	## currenty copy and pasted in seagull.
	## make a base enemy, seagull and pigeon should inherit from it
	#if (curr_x_pos - target_x_pos < 0):
		## if entity moving right, face right
		#entity_sprite.flip_h = !initial_facing_right
	#else:
		#entity_sprite.flip_h = initial_facing_right

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if get_node("SpriteOrienter") == null:
		warnings.append("Entity requires a SpriteOrienter scene component")
	if get_node("EnemyHitboxComponent") == null:
		warnings.append("Entity requires a EnemyHitboxComponent")
	return warnings

func on_game_over():
	# make so seagulls do not target player after lunch is finished
	$DetectArea.monitoring = false

func play_attack_sound():
	$Squawk.play(0.1)




