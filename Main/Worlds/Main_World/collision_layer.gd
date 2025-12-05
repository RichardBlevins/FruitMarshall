# BreakableBlockManager.gd
# Attach this script to your TileMapLayer node
extends TileMapLayer

# Dictionary to track block health: Vector2i -> int (hits remaining)
var block_health: Dictionary = {}

# Default hits required to break
@export var hits_to_break: int = 3

func _ready() -> void:
	_initialize_breakable_blocks()

# Initialize all breakable blocks with full health
func _initialize_breakable_blocks() -> void:
	var used_cells = get_used_cells()
	
	for cell_pos in used_cells:
		var tile_data = get_cell_tile_data(cell_pos)
		if tile_data:
			var block_type = tile_data.get_custom_data("block_type")
			if block_type == "break":
				block_health[cell_pos] = hits_to_break

# Called by player when hitting a block
func hit_block(tile_pos: Vector2i) -> bool:
	if not block_health.has(tile_pos):
		return false
	
	# Reduce health
	block_health[tile_pos] -= 1
	
	# Check if block should break
	if block_health[tile_pos] <= 0:
		_break_connected_blocks(tile_pos)
		return true
	
	return false

# Update block appearance based on damage
	# Alternative: You could change the tile to a damaged version
	# var damaged_atlas_coords = Vector2i(original_x + damage_level, original_y)
	# set_cell(tile_pos, 0, damaged_atlas_coords)

# Break all connected blocks using flood fill
func _break_connected_blocks(start_pos: Vector2i) -> void:
	var blocks_to_break: Array[Vector2i] = []
	var visited: Dictionary = {}
	var queue: Array[Vector2i] = [start_pos]
	
	# Flood fill to find all connected breakable blocks
	while queue.size() > 0:
		var current_pos = queue.pop_front()
		
		# Skip if already visited
		if visited.has(current_pos):
			continue
		
		visited[current_pos] = true
		
		# Check if this is a breakable block
		var tile_data = get_cell_tile_data(current_pos)
		if not tile_data:
			continue
		
		var block_type = tile_data.get_custom_data("block_type")
		if block_type != "break":
			continue
		
		# Add to destruction list
		blocks_to_break.append(current_pos)
		
		# Check all 4 adjacent cells
		var neighbors = [
			current_pos + Vector2i.RIGHT,
			current_pos + Vector2i.LEFT,
			current_pos + Vector2i.UP,
			current_pos + Vector2i.DOWN
		]
		
		for neighbor in neighbors:
			if not visited.has(neighbor):
				queue.append(neighbor)
	
	# Destroy all connected blocks with animation
	_destroy_blocks_with_effect(blocks_to_break)

# Destroy blocks with optional visual effects
func _destroy_blocks_with_effect(blocks: Array[Vector2i]) -> void:
	for i in blocks.size():
		var block_pos = blocks[i]
		
		# Remove from health tracking
		block_health.erase(block_pos)
		
		# Spawn particle effect (optional)
		_spawn_break_particles(block_pos)
		
		# Add slight delay for cascade effect
		await get_tree().create_timer(0.05 * i).timeout
		
		# Erase the tile
		erase_cell(block_pos)
# ====================================================
# Optional: Spawn particle effects when block breaks
# ==================================================== EDIT LATER!!
func _spawn_break_particles(tile_pos: Vector2i) -> void:
	# Get world position of tile
	var world_pos = map_to_local(tile_pos)
	
	# You can spawn CPUParticles2D or GPUParticles2D here
	# Example:
	# var particles = preload("res://particles/block_break.tscn").instantiate()
	# get_parent().add_child(particles)
	# particles.global_position = world_pos
	# particles.emitting = true

# Helper function to get tile position from world position
func get_tile_at_position(world_pos: Vector2) -> Vector2i:
	return local_to_map(to_local(world_pos))
