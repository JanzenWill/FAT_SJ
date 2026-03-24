extends Area2D


@export var speed = 400 #speed diver
@export var sink_speed = 40
@export var attack_duration = 0.2
@export var attack_angle = 0.8 #arm rotation
@export var attack_thrust_distance = 15 #how far spear moves


var screen_size
var is_attacking = false
var attack_timer = 0.0 #counts down attack time
var arm_rest_rotation = 0.0 #helps restore arm postition after attack
var spear_rest_position = Vector2.ZERO


func _ready() -> void:
	screen_size = get_viewport_rect().size # Get the size of the game window
	arm_rest_rotation = $ArmPivot.rotation #saves arm starting pos
	spear_rest_position = $ArmPivot/Spear.position
	
	#this is so the spear hitbox does not work unless you are attacking
	$ArmPivot/Spear/SpearHitbox/CollisionShape2D.disabled = true
	

func _start():
	position = Vector2(50, 50) #start position character
	show() #show character
	$CollisionShape2D.disabled = false# Turn collision back on


func _process(delta: float) -> void:
	var velocity = Vector2.ZERO #resets for input on mpvement

	if Input.is_action_pressed("move_right"): 	# Horizontal movement
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1

	if Input.is_action_pressed("move_down"): 	# Vertical movement
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	#makes it so that diagonal movement is not faster
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed 
		
	velocity.y += sink_speed #add sink/gravity
	position += velocity * delta	# Move the diver
	#keeps the diver on screen
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

	#make the diver tilt proboplby gonna have to change with new sprites
	var target_rotation = clamp(velocity.x * 0.020, -0.7, 0.7) #0.02 to make velocoty small enough for rotation
	rotation = lerp(rotation, target_rotation, 0.1) #move rotation 0.1 each frame
	#makes things smoove
	
	if Input.is_action_just_pressed("attack") and not is_attacking: #start attack with left click
		start_attack()

	#attack cool down
	if is_attacking:
		attack_timer -= delta #minus frams from value
		if attack_timer <= 0:
			end_attack()


func start_attack() -> void:
	is_attacking = true
	attack_timer = attack_duration
	$ArmPivot.rotation = arm_rest_rotation - attack_angle #rotate arm when attack
	
	$ArmPivot/Spear.position = spear_rest_position + Vector2(attack_thrust_distance, 0) #thrust spear forward
	
	$ArmPivot/Spear/SpearHitbox/CollisionShape2D.disabled = false #turnrson again spear hitbox
	

func end_attack() -> void:
	is_attacking = false
	$ArmPivot.rotation = arm_rest_rotation #return arm to position
	$ArmPivot/Spear.position = spear_rest_position #return spear to position
	
	$ArmPivot/Spear/SpearHitbox/CollisionShape2D.disabled = true #turn of hitbox again


'''
func _on_body_entered(body: Node2D) -> void:
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties
	# on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
'''
