extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var camera: Node3D = $CameraRig/Camera3D
@onready var animation_player: AnimationPlayer = $Mesh/AnimationPlayer


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (camera.global_basis * Vector3(input_dir.x, 0, input_dir.y))
	direction = Vector3(direction.x, 0, direction.z).normalized() * input_dir.length()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	turn_to(direction)
	
	var current_speed := velocity.length()
	const RUN_SPEED := 3.5
	const BLEND_SPEED := 0.2
	
	if current_speed > RUN_SPEED:
		animation_player.play("freehand_run", BLEND_SPEED)
	elif current_speed > 0:
		animation_player.play("freehand_walk", BLEND_SPEED, lerp(0.5, 1.75, current_speed/RUN_SPEED))
	else:
		animation_player.play("freehand_idle")
	

func turn_to(direction: Vector3) -> void:
	if direction.length() > 0:
		var yaw: float = atan2(-direction.x, -direction.z)
		yaw = lerp_angle(rotation.y, yaw, 0.20)
		rotation.y = yaw
