extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var last_lean := 0.0

@onready var camera: Node3D = $CameraRig/Camera3D
@onready var animation_player: AnimationPlayer = $Mesh/AnimationPlayer
@onready var anim_tree: AnimationTree = $AnimationTree

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
	
	if not is_on_floor():
		anim_tree.set("parameters/movement/transition_request", "fall")
	elif current_speed > RUN_SPEED:
		#print(global_basis.x)
		anim_tree.set("parameters/movement/transition_request", "run")
		var lean := direction.dot(global_basis.x)
		last_lean = lerpf(last_lean, lean, 0.4)
		anim_tree.set("parameters/run_lean/add_amount", lean)
	elif current_speed > 0:
		var walk_speed := lerpf(0.5, 1.75, current_speed/RUN_SPEED)
		anim_tree.set("parameters/movement/transition_request", "walk")
	else:
		animation_player.play("freehand_idle")
		anim_tree.set("parameters/movement/transition_request", "idle")
	

func turn_to(direction: Vector3) -> void:
	if direction.length() > 0:
		var yaw: float = atan2(-direction.x, -direction.z)
		yaw = lerp_angle(rotation.y, yaw, 0.20)
		rotation.y = yaw
