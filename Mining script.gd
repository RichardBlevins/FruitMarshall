extends Node
#would be good for terraria like game mining n stuffs

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider is TileMapLayer:
			
				#on a raycast the collision point is from where the raycast begins.
				#the normal in the raycast is the area of detection
				#
				# normal>>
				# |-------->
				# ^
				# | = collision point
			var collision_point = raycast.get_collision_point()
			var normal = raycast.get_collision_normal()
				
				# Nudge the point slightly away from the edge
			var adjusted_point = collision_point - normal * 0.5
			var local_pos = collider.to_local(adjusted_point)
			var tile_pos = collider.local_to_map(local_pos)
			var tile_data = collider.get_cell_tile_data(tile_pos)
			if tile_data:
				# Check custom data (you'll need to add this in TileSet)
				var block_type = tile_data.get_custom_data("block_type")
				print(hit_counter)
					#check if same wall is being
				match block_type:
					"breakable":
						if hit_counter > 1:
							hit_counter -= 1
						else:
							break_connected_blocks(collider, tile_pos)
							hit_counter = 3
					"regular":
						print(tile_data)

func break_connected_blocks(tilemap: TileMapLayer, start_pos: Vector2i):
	# Use iterative approach to avoid stack overflow
	var to_check = [start_pos]
	var checked = {}
	
	# Get the initial tile's source_id and atlas_coords to match identical tiles
	var initial_tile_data = tilemap.get_cell_tile_data(start_pos)
	if not initial_tile_data:
		return
	
	var initial_block_type = initial_tile_data.get_custom_data("block_type")
	var initial_source_id = tilemap.get_cell_source_id(start_pos)
	var initial_atlas_coords = tilemap.get_cell_atlas_coords(start_pos)
	
	# 4 directions (up, down, left, right)
	var directions = [
		Vector2i(0, 1),   # down
		Vector2i(0, -1),  # up
		Vector2i(1, 0),   # right
		Vector2i(-1, 0)   # left
	]
	
	# Optional: Add diagonals
	# directions.append(Vector2i(1, 1))
	# directions.append(Vector2i(1, -1))
	# directions.append(Vector2i(-1, 1))
	# directions.append(Vector2i(-1, -1))
	
	while to_check.size() > 0:
		var current_pos = to_check.pop_front()
		
		# Skip if already checked
		if checked.has(current_pos):
			continue
		
		checked[current_pos] = true
		
		# Get tile data at current position
		var tile_data = tilemap.get_cell_tile_data(current_pos)
		if not tile_data:
			continue
		
		# Check if this tile matches our criteria
		var block_type = tile_data.get_custom_data("block_type")
		var source_id = tilemap.get_cell_source_id(current_pos)
		var atlas_coords = tilemap.get_cell_atlas_coords(current_pos)
		
		# Only break if it's the same type of breakable block
		if block_type == initial_block_type and block_type == "breakable" and source_id == initial_source_id and atlas_coords == initial_atlas_coords:
			# Delete this tile
			tilemap.erase_cell(current_pos)
			
			# Add neighbors to check
			for direction in directions:
				var neighbor_pos = current_pos + direction
				if not checked.has(neighbor_pos):
					to_check.append(neighbor_pos)
