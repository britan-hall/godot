extends Node

signal player_hit(body)
signal lunch_finished
signal stats_updated
signal game_over
signal crumb_hit(body)
signal camera_change(is_out : bool)

#always call this with true as its just camera change for now
signal picture_taken(is_out : bool)

signal dash_recharged
