extends Button

func _on_button_down():
	get_tree().change_scene_to_file("res://scenes/levels/level_base.tscn")
