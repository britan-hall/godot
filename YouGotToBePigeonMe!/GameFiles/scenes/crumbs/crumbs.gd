extends Area2D

var throw_time
var velocity
var health
# Called when the node enters the scene tree for the first time.
func _ready():
	#add_to_group("crumbs") #crumbs scene is in group
	GlobalSignals.crumb_hit.connect(on_crumb_hit)
	await get_tree().create_timer(throw_time).timeout
	velocity = Vector2.ZERO
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta
	
func on_crumb_hit(body):
	if body == self:
		health -= 1
		if health <= 0:
			queue_free()
