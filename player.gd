extends Area2D

# Movement speed of the diver
@export var speed = 400

# How fast the diver sinks by default
@export var sink_speed = 40

# How long the attack lasts
@export var attack_duration = 0.2

# How much the arm rotates during the attack
@export var attack_angle = 0.8

# How far the spear moves forward during the attack
@export var attack_thrust_distance = 15

# Size of the game window
var screen_size

# Tracks whether the diver is currently attacking
var is_attacking = false

# Counts down the remaining attack time
var attack_timer = 0.0

# Stores the arm's normal rotation so it can return after attacking
var arm_rest_rotation = 0.0

# Stores the spear's normal position so it can return after attacking
var spear_rest_position = Vector2.ZERO


func _ready() -> void:
	# Get the size of the game window
	screen_size = get_viewport_rect().size
	
	# Save the arm's starting rotation
	arm_rest_rotation = $ArmPivot.rotation
	
	# Save the spear's starting position
	spear_rest_position = $ArmPivot/Spear.position
	
	print("player script started")

func _start():
	# Reset player position at the start
	position = Vector2(50, 50)
	
	# Make sure the player is visible
	show()
	
	# Turn collision back on
	$CollisionShape2D.disabled = false


func _process(delta: float) -> void:
	# The diver's movement direction for this frame
	var velocity = Vector2.ZERO

	# Horizontal movement
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1

	# Vertical movement
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	# Normalize movement so diagonal movement is not faster
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

	# Add sinking every frame
	velocity.y += sink_speed

	# Move the diver
	position += velocity * delta

	# Keep the diver on screen
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

	# Tilt the diver left or right based on horizontal movement
	var target_rotation = clamp(velocity.x * 0.020, -0.7, 0.7)
	rotation = lerp(rotation, target_rotation, 0.1)

	# Start an attack when the attack button is pressed
	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()

	# Count down the attack timer while attacking
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			end_attack()


func start_attack() -> void:
	# Mark the player as attacking
	is_attacking = true
	
	# Set the attack timer
	attack_timer = attack_duration
	
	# Rotate the arm forward during the attack
	$ArmPivot.rotation = arm_rest_rotation - attack_angle
	
	# Push the spear forward during the attack
	$ArmPivot/Spear.position = spear_rest_position + Vector2(
		attack_thrust_distance, 0
	)


func end_attack() -> void:
	# Mark the attack as finished
	is_attacking = false
	
	# Return the arm to its normal position
	$ArmPivot.rotation = arm_rest_rotation
	
	# Return the spear to its normal position
	$ArmPivot/Spear.position = spear_rest_position


'''
func _on_body_entered(body: Node2D) -> void:
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties
	# on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
'''
