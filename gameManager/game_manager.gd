extends  Node3D

var actualGridsize := 2000
var actualGridSteps := 6
var numberOfLevels := 3
var actualLevel := 1
var lightTimer := 3.0
var throwLightTimer := 1.0
var level := 1
var jumpUsed := 0

@onready var gameTheme = $"/root/GameManager/gametheme"
@onready var gameSwap = $"/root/GameManager/gameSwap"
@onready var gameSwapTimer = $"/root/GameManager/gameSwapTimer" 
@onready var control = $"/root/GameManager/control" 

func newGame():
	GameManager.actualLevel += 1
	GameManager.actualGridsize += 1000
	GameManager.actualGridSteps += 20
	if GameManager.lightTimer < 20:
		GameManager.lightTimer *= 1.5
	if GameManager.throwLightTimer < 10:
		GameManager.throwLightTimer *= 1.1

	# Load the new scene
	var new_scene = load("res://Scenes/game.tscn") as PackedScene
	var instance = new_scene.instantiate()

	level += 1

	# Properly replace the current scene
	var current_scene = get_tree().root.get_child(1)  # Assume the current scene is the first child
	get_tree().root.add_child(instance)  # Add the new scene
	get_tree().current_scene = instance
	current_scene.queue_free()
	UpdateLabels()


func handleGameTheme():
	if GameManager.gameTheme != null and  (GameManager.gameTheme as AudioStreamPlayer).playing == false:
		(GameManager.gameTheme as AudioStreamPlayer).play()

func GameSwap():
	GameManager.gameSwap.play()
	GameManager.gameSwapTimer.start()

func _on_game_swap_timer_timeout() -> void:
	GameManager.newGame()
	pass # Replace with function body.

func UpdateLabels():
	if jumpUsed > 0:
		control.get_node("%jumpLabel").visible = true
	control.get_node("%levelLabel").text = "Level: " + str(level)
	control.get_node("%jumpLabel").text = "Jumps: " + str(jumpUsed)
