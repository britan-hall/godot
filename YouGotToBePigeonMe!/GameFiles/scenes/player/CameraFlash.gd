extends Polygon2D
var is_waxing = false 
#moon terminogy means the flash is coming on if true otherwise it goes away
var time = 1
@export var flash_on_multi = 12
@export var flash_off_multi = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	
	#if !is_waxing:
	modulate.a = 1 + -1 * time * flash_off_multi
	
	
	if is_waxing:
		modulate.a = time * flash_on_multi
		if modulate.a >= 1:
			is_waxing = false
			time = 0
	
		 


func _on_player_camera_taking():
	is_waxing = true
	time = 0
	
