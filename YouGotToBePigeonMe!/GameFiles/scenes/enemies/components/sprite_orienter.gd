extends Node

# face correct directions, assuming facing right is default
func face_direction(curr_x_pos: float, target_x_pos: float, entity_sprite: Sprite2D, initial_facing_right: bool = true) -> void:
	# TODO: MAKE THIS INTO FUNCTION
	# currenty copy and pasted in seagull.
	# make a base enemy, seagull and pigeon should inherit from it
	if (curr_x_pos - target_x_pos < 0):
		# if entity moving right, face right
		entity_sprite.flip_h = !initial_facing_right
	else:
		entity_sprite.flip_h = initial_facing_right

func scream():
	print("AAAAAAAAAAAAAAAAH")
