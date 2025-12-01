extends Node

const SAVE_PATH = "user://savegame.save"

var save_data = {
	"player_position": Vector2.ZERO,
	"max_health": 20.0,
	"abilities": [],
	"items": [],
	"explored_rooms": [],
	"defeated_enemies": [],
	"save_station": "",
	"playtime": 0.0
}

func _ready() -> void:
	pass

func save_game(player_data: Dictionary):
		# Update save_data with new player info
	for key in player_data.keys():
		save_data[key] = player_data[key]
	
	# Open file for writing
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file == null:
		print("Error: Could not open save file for writing")
		return false
	
	# Convert to JSON and save
	var json_string = JSON.stringify(save_data)
	save_file.store_line(json_string)
	save_file.close()
	
	print("Game saved successfully!")
	return true

# Load the game
func load_game() -> Dictionary:
	# Check if save file exists
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found")
		return {}
	
	# Open file for reading
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if save_file == null:
		print("Error: Could not open save file for reading")
		return {}
	
	# Read and parse JSON
	var json_string = save_file.get_line()
	save_file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result == OK:
		save_data = json.data
		print("Game loaded successfully!")
		return save_data
	else:
		print("Error parsing save file")
		return {}

# Check if a save file exists
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

# Delete save file
func delete_save():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("Save file deleted")

# Helper functions for specific data
func unlock_ability(ability_name: String):
	if ability_name not in save_data["abilities"]:
		save_data["abilities"].append(ability_name)

func has_ability(ability_name: String) -> bool:
	return ability_name in save_data["abilities"]

func add_item(item_name: String):
	if item_name not in save_data["items"]:
		save_data["items"].append(item_name)

func has_item(item_name: String) -> bool:
	return item_name in save_data["items"]

func mark_room_explored(room_name: String):
	if room_name not in save_data["explored_rooms"]:
		save_data["explored_rooms"].append(room_name)

func is_room_explored(room_name: String) -> bool:
	return room_name in save_data["explored_rooms"]

func mark_enemy_defeated(enemy_id: String):
	if enemy_id not in save_data["defeated_enemies"]:
		save_data["defeated_enemies"].append(enemy_id)

func is_enemy_defeated(enemy_id: String) -> bool:
	return enemy_id in save_data["defeated_enemies"]

		
