extends StaticBody3D

var velocity: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += velocity * delta
	pass


func _on_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.
