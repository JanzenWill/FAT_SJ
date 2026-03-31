extends RigidBody2D

@export var gravity = 0
@export var max_health = 1 #health
@export var damage = 0 #damage it takes

var health = max_health
var velocity = Vector2.ZERO
var direction = 1
var speed = 130

signal killed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health
	linear_velocity = Vector2(speed * direction, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	velocity.y += gravity * delta
#	position += velocity * delta


func _on_mob_timer_timeout() -> void:
	pass # Replace with function body.


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("spear"):
		if area.has_method("get_damage"):
			take_damage(area.get_damage())
		else:
			take_damage(1)
	

func _physics_process(delta):
	$AnimatedSprite2D.flip_h = linear_velocity.x < 0

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var vel  = state.linear_velocity
	vel.x = speed * direction
	state.linear_velocity = vel


func _on_visible_on_screen_notifier_2d_screen_exited() -> void: #makes them disapear off screen dont know if we want that
	queue_free() # Replace with function body.
	
func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	killed.emit()
	queue_free()

func get_damage() -> int:
	return damage
