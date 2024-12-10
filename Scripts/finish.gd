extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_static_body_3d_2_body_entered(body:Node3D) -> void:
	if(body.is_in_group("Player")):
		print("you win")
		# if GameManager.actualLevel < GameManager.numberOfLevels:
		# Update game state
		GameManager.actualLevel += 1
		GameManager.actualGridsize += 2000
		GameManager.actualGridSteps += 50

		# Load the new scene
		var new_scene = load("res://Scenes/game.tscn") as PackedScene
		var instance = new_scene.instantiate()

		# Properly replace the current scene
		var current_scene = get_tree().root.get_child(1)  # Assume the current scene is the first child
		get_tree().root.add_child(instance)  # Add the new scene
		get_tree().current_scene = instance
		# Defer freeing the current scene
		current_scene.queue_free()
		print("Scene Tree After Switch:")	
		get_tree().root.print_tree()
		handleGameTheme()
		# else:
			# print("No more levels")
	pass # Replace with function body.

func handleGameTheme():
	if GameManager.gameTheme != null and  (GameManager.gameTheme as AudioStreamPlayer).playing == false:
		(GameManager.gameTheme as AudioStreamPlayer).play()