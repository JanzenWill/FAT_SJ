extends RigidBody2D

@export var gravity = 0
@export var max_health = 1 # health
@export var damage = 0 # damage it gives
@export var knockback_strength = 200

var health = max_health
var is_hit = false
var velocity = Vector2.ZERO
var direction = 1
var speed = 130

signal killed

func _ready() -> void:
	health = max_health
	linear_velocity = Vector2(speed * direction, 0)
	lock_rotation = true

#func _process(delta: float) -> void:
#	velocity.y += gravity * delta
#	position += velocity * delta

func _on_mob_timer_timeout() -> void:
	pass

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Trident"):
		if area.has_method("get_damage"):
			take_damage(area.get_damage(), area.global_position.x)
		else:
			take_damage(1, area.global_position.x)

func _physics_process(_delta: float) -> void:
	$AnimatedSprite2D.flip_h = linear_velocity.x < 0

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var vel = state.linear_velocity
	vel.x = speed * direction
	state.linear_velocity = vel

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func take_damage(amount: int, hit_from_x: float) -> void:
	health -= amount

	if health <= 0:
		die()
		return

	show_hit_flash()

	var hit_direction = sign(hit_from_x - global_position.x)
	if hit_direction == 0:
		hit_direction = 1

	linear_velocity.x -= hit_direction * knockback_strength

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
