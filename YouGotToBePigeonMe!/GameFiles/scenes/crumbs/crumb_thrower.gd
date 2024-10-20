extends Node2D
@export var crumb_scene: PackedScene
@export var throw_time:float = 1
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_player_throw(player_pos, throw_pos):
	# Create a new instance of the Mob scene.
	var crumb = crumb_scene.instantiate()
	## Set the mob's position
	crumb.global_position = player_pos
	crumb.throw_time = throw_time
	crumb.velocity = (throw_pos - player_pos) / throw_time
	crumb.health = 2
	## Spawn the mob by adding it to the Main scene.
	add_child(crumb)
	print(get_tree().get_nodes_in_group("crumbs").size())
	pass
