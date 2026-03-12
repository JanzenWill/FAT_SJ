extends Area2D

@export var speed = 400
@export var sink_speed = 40   # how fast the diver sinks by default

var screen_size


func _ready() -> void:
	screen_size = get_viewport_rect().size
	print("player script started")


func _start():
	position = Vector2(50, 50)
	show()
	$CollisionShape2D.disabled = false


func _process(delta: float) -> void:
	var velocity = Vector2.ZERO

	# Horizontal movement
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1

	# Vertical input
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	# Normalize only player input movement
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

	# Add sinking every frame
	velocity.y += sink_speed

	position += velocity * delta

	# Keep diver on screen
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	
	var target_rotation = clamp(velocity.x * 0.020, -0.7, 0.7)
	rotation = lerp(rotation, target_rotation, 0.1)

'''
func _on_body_entered(body: Node2D) -> void:
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
'''	
