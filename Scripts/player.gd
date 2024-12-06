extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVTY :=  0.001

#bob variables 
const BOB_FREQ := 2.0
const BOB_AMP := 0.1
var bob_timer := 0.0

#light variables
var Light = preload("res://Scenes/Light.tscn")
var throwingForce = -20
var lightIntesity = 10
var canthrow = true

var throwTimerTime = 1.0:
	get:
		return throwTimerTime
	set(value):
		throwTimerTime= value
		set_throw_timerTime(value)
	
func set_throw_timerTime(value):
	throwTimer.wait_time = value

@onready var head = $Head
@onready var camera = $Head/Camera
@onready var lightPos = $Head/LightPos
@onready var throwTimer = $ThrowTimer

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVTY)
		camera.rotate_x(-event.relative.y * SENSITIVTY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(40))
	if event.is_action_pressed("right_click"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("move_jump") : ##and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction: Vector3 = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	#HEad bob 
	bob_timer +=  delta * velocity.length() * float(is_on_floor()) # is on floor will give 1 or 0 so it will make the bob_timer = 0 when the player is in air
	camera.transform.origin = _headbob(bob_timer)

	move_and_slide()

	lightThrow()

func _headbob(timer: float) -> Vector3:
	var bob_offset = Vector3(0, 0, 0)
	bob_offset.y = abs(sin(timer * BOB_FREQ)) * BOB_AMP
	bob_offset.x = abs(cos(timer * BOB_FREQ * 0.5)) * BOB_AMP 
	return bob_offset

func lightThrow():
	if Input.is_action_just_released("left_click") && canthrow:
		var light_instance = Light.instantiate()
		light_instance.position = lightPos.global_position
		# light_instance.global_transform = lightPos.global_transform
		# get_parent().add_child(light_instance)
		# light_instance.lightThrow()
		canthrow = false
		throwTimer.start()
		get_tree().current_scene.add_child(light_instance)

		var playerRotation = head.global_transform.basis.z.normalized()

		light_instance.apply_central_impulse(playerRotation * throwingForce)


func _on_throw_timer_timeout() -> void:
	canthrow = true
	pass # Replace with function body.
