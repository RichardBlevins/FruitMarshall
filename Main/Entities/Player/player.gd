extends CharacterBody2D

# Movement and other player values
@export var speed: float = 100.0
@export var jump_velocity: float = -320.0
@export var gravity: float = 1000.0
@export var knockback_force: float = 250.0

# main player values
@export var max_health: float = 20.0

# Combat
@export var held_item = null
@export var attack_duration: float = 0.4

# State
var is_attack_ready: bool = true
var facing_direction: int = 1

# Nodes
@onready var interaction_raycast: RayCast2D = $RayCast2D
@onready var punch_area: Area2D = $Punch
@onready var menu = $Menu

# Constants
const RAYCAST_RANGE: float = 21.0
const PUNCH_OFFSET: float = 13.0

# =============================================
# SAVE HANDLE
# =============================================

func save_player_data():
	var player_data = {
		"max_health": max_health
	}
	SaveManager.save_game(player_data)

func load_player_data():
	var data = SaveManager.load_game()
	if data.is_empty():
		return  # No save file, start new game

	max_health = data.get("max_health", 20.0)

func _ready() -> void:
	punch_area.area_entered.connect(_on_punch_hit)
	load_player_data()

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump()
	_handle_movement()
	_handle_gui()
	_handle_attack()
	move_and_slide()
	
	

# ============================================
# MOVEMENT
# ============================================

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
		#applys gravity

func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	elif Input.is_action_just_released("jump") and velocity.y < 20:
		velocity.y = 0

func _handle_movement() -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		velocity.x = direction * speed
		_update_facing_direction(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)


func _update_facing_direction(direction: float) -> void:
	facing_direction = int(direction)
	
	var horizontal_offset = RAYCAST_RANGE * facing_direction
	interaction_raycast.target_position = Vector2(horizontal_offset, 0)
	punch_area.position = Vector2(PUNCH_OFFSET * facing_direction, 0)

# ============================================
# COMBAT
# ============================================

func _handle_attack() -> void:
	if not Input.is_action_just_pressed("attack") or not is_attack_ready:
		return
	
	match held_item:
		null:
			_execute_punch()
	
	_check_tile_collision()

func _execute_punch() -> void:
	is_attack_ready = false
	punch_area.visible = true
	punch_area.monitoring = true
	await get_tree().create_timer(attack_duration).timeout
	punch_area.visible = false
	punch_area.monitoring = false
	is_attack_ready = true

# ============================================
# BLOCK TYPE HANDLER
# ============================================

func _check_tile_collision() -> void:
	if not interaction_raycast.is_colliding():
		return
	
	var collider = interaction_raycast.get_collider()
	if not collider is TileMapLayer:
		return
	
	
	var tile_data = _get_tile_data_at_raycast(collider)
	if not tile_data:
		return
	
	var block_type = tile_data.get_custom_data("block_type")
	
	match block_type:
		"regular":
			_apply_knockback()
		"break":
			_handle_breakable_block(collider)

func _handle_breakable_block(tilemap: TileMapLayer) -> void:
	# Apply knockback when hitting breakable blocks
	_apply_knockback()
	
	# Get the tile position
	var collision_point = interaction_raycast.get_collision_point()
	var normal = interaction_raycast.get_collision_normal()
	var adjusted_point = collision_point - normal * 0.5
	var tile_pos = tilemap.get_tile_at_position(adjusted_point)
	
	# Hit the block (returns true if it broke)
	var did_break = tilemap.hit_block(tile_pos)
	
	
	if did_break:
		# Optional: Add screen shake, sound effect, etc.
		_play_block_break_effect()

# ============================================
# MOVEMENT / COMBAT (DETECT USING RAYCAST)
# ============================================

func _get_tile_data_at_raycast(tilemap: TileMapLayer) -> TileData:
	var collision_point = interaction_raycast.get_collision_point()
	var normal = interaction_raycast.get_collision_normal()
	
	var adjusted_point = collision_point - normal * 0.5
	var local_pos = tilemap.to_local(adjusted_point)
	var tile_pos = tilemap.local_to_map(local_pos)
	
	return tilemap.get_cell_tile_data(tile_pos)

func _apply_knockback() -> void:
	velocity.x = -facing_direction * knockback_force

func _play_block_break_effect() -> void:
	# Add screen shake, play sound, etc.
	# Example: $Camera2D.apply_shake(0.2, 5)
	# Example: $AudioStreamPlayer.play()
	pass

# ============================================
# SIGNALS
# ============================================

func _on_punch_hit(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		_apply_knockback()
		print("Punch hit: ", area.name)
		
# ============================================
# GUI BINDS
# ============================================

func _handle_gui() -> void:
	if Input.is_action_just_pressed("menu"):
		Gamemanger.toggle_pause()
		match Gamemanger.is_paused:
			false:
				menu.visible = false
			true:
				menu.visible = true
				
	
