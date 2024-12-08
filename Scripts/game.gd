extends Node3D

const dir = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]

var grid_size = 2000
var grid_steps = 100 #number of tiles ?
var wall_height = 4
var _isRoofEnable: bool = false

var isRoofEnableEditable = false:
	get:
		return _isRoofEnable
	set(value):
		_isRoofEnable = value
		set_roof_enable(value)

func set_roof_enable(value):
	if value:
		add_roof()
	else:
		remove_roof()

var tilesAlreadyPresent = [Vector2(0,0),Vector2(-1,0), Vector2(0,-1), Vector2(-1,-1) ]

func _ready():
	setDefaultSpawn()
	randomize()
	var current_pos = Vector2(0, 0)
	var position_stack = tilesAlreadyPresent + [current_pos]  # Stack for backtracking
	tilesAlreadyPresent.append(current_pos)

	for i in range(grid_steps):
		if position_stack.is_empty():
			print("No more positions to backtrack to!")
			break

		current_pos = position_stack[-1]  # Get the last position from the stack
		var temp_dir = dir.duplicate()
		temp_dir.shuffle()
		var possible_dirs = temp_dir.duplicate()
		var found_valid = false
		var first_tile = Vector2()
		var second_tile = Vector2()

		for d in temp_dir:
			first_tile = current_pos + d

			# Check grid boundaries and duplication for the first tile
			if abs(first_tile.x) > grid_size or abs(first_tile.y) > grid_size:
				continue
			if first_tile in tilesAlreadyPresent:
				continue
			
			if  not has_minimum_neighbors(first_tile):
				continue

			# Find a neighboring tile to place next to the first tile
			for d2 in possible_dirs:
				second_tile = first_tile + d2

				# Check grid boundaries and duplication for the second tile
				if abs(second_tile.x) > grid_size or abs(second_tile.y) > grid_size:
					continue
				if second_tile in tilesAlreadyPresent:
					continue
				if not has_minimum_neighbors(second_tile):
					continue

				# If both tiles pass the checks, add them
				found_valid = true
				break

			if found_valid:
				break

		if found_valid:
			tilesAlreadyPresent.append(first_tile)
			tilesAlreadyPresent.append(second_tile)
			position_stack.append(first_tile)
			position_stack.append(second_tile)

			$GridMap.set_cell_item(Vector3i(int(first_tile.x), 0, int(first_tile.y)), 0, 0)
			$GridMap.set_cell_item(Vector3i(int(second_tile.x), 0, int(second_tile.y)), 0, 0)
		
		else:
			print("No valid direction found from", current_pos)
			position_stack.pop_back()  # Backtrack to the previous position

	# Add roof and walls after generating the grid
	add_roof()
	add_walls()
	add_finish()

func has_minimum_neighbors(pos: Vector2) -> bool:
	var orthogonal_offsets = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
	var diagonal_offsets = [Vector2(1, 1), Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1)]

	var orthogonal_neighbors = []
	var diagonal_neighbors = []

	# Count orthogonal neighbors
	for offset in orthogonal_offsets:
		var neighbor_pos = pos + offset
		if neighbor_pos in tilesAlreadyPresent:
			orthogonal_neighbors.append(neighbor_pos)

	# Count diagonal neighbors
	for offset in diagonal_offsets:
		var neighbor_pos = pos + offset
		if neighbor_pos in tilesAlreadyPresent:
			diagonal_neighbors.append(neighbor_pos)

	# Relaxed check: Allow placement with 1 orthogonal neighbor in early stages
	if orthogonal_neighbors.size() == 0:
		print("Rejected:", pos, "Reason: No orthogonal neighbors.")
		return false

	# Restrict diagonal connections: Each diagonal must share an orthogonal with `pos`
	for diag in diagonal_neighbors:
		var shared_orthogonal = false
		for ortho in orthogonal_neighbors:
			if abs(diag.x - ortho.x) + abs(diag.y - ortho.y) == 1:  # Shared orthogonal logic
				shared_orthogonal = true
				break
		if not shared_orthogonal:
			print("Rejected:", pos, "Reason: Diagonal neighbor without shared orthogonal.")
			return false

	# Prevent narrow corridors by disallowing exactly 2 orthogonal neighbors opposite each other
	if orthogonal_neighbors.size() == 2:
		var directions = []
		for ortho in orthogonal_neighbors:
			directions.append(ortho - pos)
		if directions[0] + directions[1] == Vector2(0, 0):  # Opposite neighbors
			print("Rejected:", pos, "Reason: Linear corridor.")
			return false

	# Allow placement
	return true



func setDefaultSpawn():
	for v in tilesAlreadyPresent:
		$GridMap.set_cell_item(Vector3i(int(v.x), 0, int(v.y)), 0, 0)

func add_roof():
	if isRoofEnableEditable:
		for v in tilesAlreadyPresent:
			$GridMap.set_cell_item(Vector3i(int(v.x), 5, int(v.y)), 0, 0)

func remove_roof():
	for v in tilesAlreadyPresent:
		$GridMap.set_cell_item(Vector3i(int(v.x), 5, int(v.y)), -1, 0)

func add_walls():
	var neighbor_offsets = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]

	for tile in tilesAlreadyPresent:
		for offset in neighbor_offsets:
			var neighbor_pos = tile + offset
			if neighbor_pos not in tilesAlreadyPresent:  # If the position is empty
				for height in range(wall_height):  # Build a 3-tall wall				
					# random between 1 and 4 
					# var random_value = randi() % 4 + 1
					$GridMap.set_cell_item(Vector3i(int(neighbor_pos.x), height, int(neighbor_pos.y)), 2, 0)  # Replace '1' with wall ID

func add_finish():
	#select a random tile from the furthest tiles from the start (0,0) and add the finish line	
	# Start position
	var start_pos = Vector2(0, 0)

	# Calculate distances of all tiles from the start
	var max_distance = 0
	var furthest_tiles = []

	for tile in tilesAlreadyPresent:
		var distance = start_pos.distance_to(tile)

		# Update max distance and furthest tiles
		if distance > max_distance:
			max_distance = distance
			furthest_tiles = [tile]  # Start a new list with this tile
		elif distance == max_distance:
			furthest_tiles.append(tile)  # Add to the list of furthest tiles

	# Select a random tile from the furthest tiles
	if furthest_tiles.size() > 0:
		var finish_tile = furthest_tiles[randi() % furthest_tiles.size()]
		print("Finish line placed at:", finish_tile)

		# Add the finish line (use your preferred method to represent it)
		$GridMap.set_cell_item(Vector3i(int(finish_tile.x), 0, int(finish_tile.y)), 5, 0)
	else:
		print("No tiles available for placing the finish line!")
