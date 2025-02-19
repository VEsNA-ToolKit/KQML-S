extends CharacterBody3D

const SPEED = 10.0
const JUMP_VELOCITY = 4.5

@onready var idle_anim = $Body/Idle
@onready var run_anim = $Body/Run
@onready var jump_anim = $Body/Jump

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
	var direction := Vector3( input_dir.y, 0, input_dir.x ).normalized()
	if direction:
		run_anim.play( "Root|Run" )
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		rotation.y = atan2( -direction.z, direction.x )
		run_anim.play( "Root|Run" )
	else:
		if run_anim.is_playing():
			run_anim.stop()
		idle_anim.play( "Root|Idle" )
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
