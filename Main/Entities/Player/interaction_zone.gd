extends Area2D

var is_collide: bool = false

func toggle_collide() -> void:
	is_collide = !is_collide

func _input(event):
	if event.is_action_pressed("ui_up") and is_collide == true:  
		SaveManager.data.Player_Position = Gamemanger.get_player_position()
		SaveManager.save_data()

#CHECKS IF PLAYER IS IN ZONE

func _on_area_entered(area: Area2D) -> void:
	for group_name in area.get_groups():
		match group_name:
			"savepoint":
				toggle_collide()

func _on_area_exited(area: Area2D) -> void:
	for group_name in area.get_groups():
		match group_name:
			"savepoint":
				toggle_collide()
