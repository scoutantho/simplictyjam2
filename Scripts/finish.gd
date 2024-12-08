extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_static_body_3d_2_body_entered(body:Node3D) -> void:
	# if(body.is_in_group("Player")):
	print("you win") 
	pass # Replace with function body.
