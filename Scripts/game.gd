extends Node3D

const dir = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]

var grid_size = 2000
var grid_steps = 100 #number of tiles ?
var wall_height = 3
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
		var d = temp_dir.pop_front()
		var found_valid = false

		while temp_dir.size() > 0:
			var new_pos = current_pos + d

			# Check grid boundaries, duplicate tiles, and minimum neighbor condition
			if abs(new_pos.x) <= grid_size and abs(new_pos.y) <= grid_size and new_pos not in tilesAlreadyPresent:
				if tilesAlreadyPresent.size() < 6 or has_minimum_neighbors(new_pos):
					found_valid = true
					break

			d = temp_dir.pop_front()

		if found_valid:
			var new_pos = current_pos + d
			tilesAlreadyPresent.append(new_pos)
			position_stack.append(new_pos)  # Push the new position to the stack

			$GridMap.set_cell_item(Vector3i(int(new_pos.x), 0, int(new_pos.y)), 0, 0)
		else:
			print("No valid direction found from", current_pos)
			position_stack.pop_back()  # Backtrack to the previous position

	# Add roof and walls after generating the grid
	add_roof()
	add_walls()

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
					var random_value = randi() % 4 + 1
					$GridMap.set_cell_item(Vector3i(int(neighbor_pos.x), height, int(neighbor_pos.y)), random_value, 0)  # Replace '1' with wall ID
