extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Show save prompt
		print("Press the up arrow to save")

func _input(event):
	if event.is_action_pressed("ui_up"):  # Or your interact key
		var overlapping = get_overlapping_bodies()
		if overlapping.size() > 0 and overlapping[0].is_in_group("player"):
			overlapping[0].save_player_data()
