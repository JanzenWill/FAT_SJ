extends RigidBody2D

@export var gravity = 0
@export var max_health = 2 # health
@export var damage = 1 # damage it gives
@export var knockback_strength = 200

@export var patrol_speed = 200.0 # normal left/right swim speed
@export var chase_speed = 200.0 # faster speed while chasing player
@export var leash_time = 1.5 # how long it keeps chasing after player leaves range
@export var tilt_strength = 0.0035 # how much fish rotates based on movement
@export var tilt_lerp_speed = 0.18 # how quickly rotation catches up

var direction = 1 # patrol direction: 1 = right, -1 = left
var is_hit = false
var health = max_health
var velocity = Vector2.ZERO

var player: Node2D = null # stores player reference while chasing
var is_chasing = false # true while actively chasing
var player_in_range = false # true while player is inside big detection area
var leash_timer = 0.0 # counts down after player leaves area

signal killed

func _ready() -> void:
	health = max_health
	linear_velocity = Vector2(patrol_speed * direction, 0)

"""
func _process(delta: float) -> void:
	velocity.y += gravity * delta
	position += velocity * delta
"""

func _integrate_forces(state) -> void:
	var vel = state.linear_velocity

	# If chasing and we still know where the player is,
	# swim toward them in all directions.
	if is_chasing and player != null:
		var to_player = player.global_position - global_position

		if to_player.length() > 0:
			vel = to_player.normalized() * chase_speed
		else:
			vel = Vector2.ZERO

	# Otherwise go back to simple left/right patrol.
	else:
		vel.x = patrol_speed * direction
		vel.y = 0

	state.linear_velocity = vel

func _physics_process(delta: float) -> void:
	# Flip sprite based on horizontal movement.
	$AnimatedSprite2D.flip_h = linear_velocity.x < 0

	# Only tilt while chasing so normal patrol stays flat.
	var target_rotation = 0.0

	if is_chasing:
		target_rotation = clamp(
			(linear_velocity.x * tilt_strength) + (linear_velocity.y * tilt_strength * 0.5),
			-0.9,
			0.9
		)

	rotation = lerp(rotation, target_rotation, tilt_lerp_speed)

	# Leash behavior:
	# if player left range, keep chasing for a bit, then stop.
	if is_chasing and not player_in_range:
		leash_timer -= delta
		if leash_timer <= 0:
			stop_chasing()
			stop_chasing()

func _on_mob_timer_timeout() -> void:
	pass

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

# Small hit area for spear only.
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("spear"):
		if area.has_method("get_damage"):
			take_damage(area.get_damage(), area.global_position.x)
		else:
			take_damage(1, area.global_position.x)

# Big detection area for player aggro/chasing.
func _on_detection_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		player = area
		player_in_range = true
		is_chasing = true
		leash_timer = leash_time

# When player leaves the big detection area,
# do not stop instantly — start leash countdown instead.
func _on_detection_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("player") and area == player:
		player_in_range = false
		leash_timer = leash_time

# Stop chasing and smoothly go back to patrol.
func stop_chasing() -> void:
	is_chasing = false
	player_in_range = false
	player = null

	# Pick patrol direction based on last horizontal movement,
	# so it keeps swimming naturally instead of snapping weirdly.
	if linear_velocity.x > 0:
		direction = 1
	elif linear_velocity.x < 0:
		direction = -1

	linear_velocity = Vector2(patrol_speed * direction, 0)

func take_damage(amount: int, hit_from_x: float) -> void:
	health -= amount

	if health <= 0:
		die()
		return

	show_hit_flash()

	# Knock fish away from where it was hit.
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
