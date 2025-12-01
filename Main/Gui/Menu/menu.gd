extends CanvasLayer

@onready var player: CharacterBody2D = $".."

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _on_resume_pressed() -> void:
	Gamemanger.toggle_pause()
	visible = false

func _on_quit_pressed() -> void:
	if player:
		player.save_player_data()
