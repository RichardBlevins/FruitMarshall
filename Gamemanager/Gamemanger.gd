extends Node

var is_paused: bool = false

func toggle_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused
