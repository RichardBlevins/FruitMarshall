extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _on_resume_pressed() -> void:
	Gamemanger.toggle_pause()
	visible = false


func _on_save_pressed() -> void:
	pass


func _on_quit_pressed() -> void:
	pass # Replace with function body.
