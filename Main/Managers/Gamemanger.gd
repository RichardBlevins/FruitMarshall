extends Node

#this allows me to pause the game through a single function whenever
var is_paused: bool = false

func toggle_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused

# Node2d is null right now but this function below when called in the player with the self property player is nolonger a node2d.
# player is the actual plaher node
var player: Node2D = null
func set_player(p: Node2D):
	player = p

func get_player_position() -> Vector2:
	if player:
		return player.global_position
	return Vector2.ZERO
