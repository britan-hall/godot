extends Area2D
@export var player_stats: Resource
var in_picture = []
@export var album: Album
# dict used as a set

# Called when the node enters the scene tree for the first time.
func _ready():
	set_visible(false)
	album.album = {}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	look_at(player_stats.player_facing + player_stats.player_pos)
	


func _on_player_camera_out(is_camera_out):
	set_visible(is_camera_out)
	#set_visible(!visible)


func _on_player_camera_taking():
	for enemy in in_picture:
		album.album[enemy.get_parent()] = "dummy"
		#print(enemy.get_parent().name)
	#print(in_picture.size())
	#print(album.album.size())
	pass # Replace with function body.


func _on_area_entered(area):
	if area.name != "DetectArea":
		in_picture.append(area)
	pass # Replace with function body.


func _on_area_exited(area):
	in_picture.erase(area)
	pass # Replace with function body.
	
