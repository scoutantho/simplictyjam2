extends Node3D

const dir = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]

var grid_size = 100
var grid_steps = 500 #number of tiles ?
var wall_height = 3
var _isRoofEnable: bool = true

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
	var current_pos = Vector2(0,0)
	
	var current_dir = Vector2.RIGHT
	var last_dir = current_dir * -1
	
	for i in range(grid_steps):
		var temp_dir = dir.duplicate()
		temp_dir.shuffle()
		var d = temp_dir.pop_front()

		while temp_dir.size() > 0:  # Ensure we don't exhaust all directions without valid movement
			var new_pos = current_pos + d
			
		# Check grid boundaries and duplicate tiles
			if abs(new_pos.x) <= grid_size and abs(new_pos.y) <= grid_size and new_pos not in tilesAlreadyPresent:
				break  # Valid direction found
				
			# Try another direction
			d = temp_dir.pop_front()
			
		# Check if a valid direction was found
		var new_pos = current_pos + d
		if abs(new_pos.x) <= grid_size and abs(new_pos.y) <= grid_size and new_pos not in tilesAlreadyPresent:
			current_pos = new_pos
			tilesAlreadyPresent.append(current_pos)
			$GridMap.set_cell_item(Vector3i(int(current_pos.x), 0, int(current_pos.y)), 0, 0)
			# $GridMap.set_cell_item(Vector3i(int(current_pos.x), 5, int(current_pos.y)), 0, 0)
	add_roof()
	add_walls()

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
					$GridMap.set_cell_item(Vector3i(int(neighbor_pos.x), height, int(neighbor_pos.y)), 1, 0)  # Replace '1' with wall ID