extends RigidBody2D

@export var gravity = 0
@export var max_health = 2 #health
@export var damage = 1 #damage it takes
@export var knockback_strength = 200


var is_hit = false
var health = max_health
var velocity = Vector2.ZERO

signal killed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
"""
func _process(delta: float) -> void:
	velocity.y += gravity * delta
	position += velocity * delta
"""

func _on_mob_timer_timeout() -> void:
	pass # Replace with function body.


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _physics_process(delta):
	$AnimatedSprite2D.flip_h = linear_velocity.x < 0 #flips sprite

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("spear"):
		if area.has_method("get_damage"):
			take_damage(area.get_damage(), area.global_position.x)
		else:
			take_damage(1, area.global_position.x)
		
func take_damage(amount: int, hit_from_x: float) -> void:
	health -= amount
	if health <= 0:
		die()
	show_hit_flash()
	
	var direction = sign(hit_from_x - global_position.x)
	if direction == 0:
		direction = 1

	linear_velocity.x -= direction * knockback_strength

	
func die() -> void:
	killed.emit()
	queue_free()

func get_damage() -> int:
	return damage
	
func show_hit_flash() -> void:
	if is_hit:
		return

	is_hit = true
	$AnimatedSprite2D.modulate = Color(1, 0.4, 0.4)
	await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.modulate = Color(1, 1, 1)
	is_hit = false
