extends Area2D

@export var damage_rate: float = 0.5
func _ready():
	$DamageRateTimer.wait_time = damage_rate


func _on_damage_rate_timer_timeout():
	for node in get_overlapping_bodies():
		deal_damage(node)

func deal_damage(body):
	if body.name == "Player":
		GlobalSignals.player_hit.emit(get_parent())
	if body.is_in_group("crumbs") && !get_parent().is_in_group("child"):
		GlobalSignals.crumb_hit.emit(body)


func _on_body_entered(body):
	deal_damage(body)
	$DamageRateTimer.start()


func _on_area_entered(area):
	for node in get_overlapping_areas():
		deal_damage(node)
