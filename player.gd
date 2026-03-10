extends Area2D

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	print("player script started")
	#print("player loaded")
	#hide()

func _start():
	position = Vector2(50, 50)
	show()
	$CollisionShape2D.disabled = false


func _process(delta: float) -> void:
	var velocity = Vector2.ZERO # The player's movement vector.
	#print(Input.get_connected_joypads())
	#print(Input.is_anything_pressed())
	
	if Input.is_action_pressed("move_right"):
		print("right pressed")
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	

'''
func _on_body_entered(body: Node2D) -> void:
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
'''	
