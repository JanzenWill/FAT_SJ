extends RigidBody2D

@export var gravity = 0
@export var max_health = 5 #health
@export var damage = 2 #damage it gives

var speed = 300
var direction = 1
var health = max_health
var velocity = Vector2.ZERO

#signal killed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	linear_velocity = Vector2(speed * direction, 0)

"""
func _process(delta: float) -> void:
	velocity.y += gravity * delta
	position += velocity * delta
"""

func integrate_forces(state):
	var vel  = state.linear_velocity
	vel.x = speed * direction
	state.linear_velocity = vel


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _physics_process(delta):
	$AnimatedSprite2D.flip_h = linear_velocity.x < 0 #flips sprite

'''
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("spear"):
		if area.has_method("get_damage"):
			take_damage(area.get_damage())
		else:
			take_damage(1)
'''

'''	
func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	killed.emit()
	queue_free()

func get_damage() -> int:
	return damage
'''
