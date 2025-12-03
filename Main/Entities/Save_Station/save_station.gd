extends Area2D


func _input(event):
	if event.is_action_pressed("ui_up"):  # Or your interact key
		var overlapping = get_overlapping_bodies()
		if overlapping.size() > 0 and overlapping[0].is_in_group("player"):
			overlapping[0].save_player_data()


func _on_area_entered(area: Area2D) -> void:
	print("saved")
	if area.is_in_group("player"):
		# Show save prompt
		print("Press the up arrow to save")
