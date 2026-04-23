extends RigidBody2D

@export var gravity = 0
@export var max_health = 2 # health
@export var damage = 1 # damage it gives
@export var knockback_strength = 600
@export var patrol_speed = 190.0 # normal left/right swim speed
@export var chase_speed = 250.0 # faster speed while chasing player
@export var leash_time = 1.5 # how long it keeps chasing after player leaves range
@export var tilt_strength = 0.0018 # how much fish rotates based on movement
@export var tilt_lerp_speed = 0.08 #0.18 # how quickly rotation catches up
@export var direction = 1 # patrol direction: 1 = right, -1 = left
@export var speed_variability_factor = 1.05
@export var attack_knockback_strength: float = 1000
@export var score_value: int = 3
@export var preferred_min_distance: float = 25
@export var preferred_max_distance: float = 70
@export var backoff_speed: float = 120.0

var knockback_velocity = Vector2.ZERO
var knockback_timer = 0.0
var despawn_distance = 2000

var is_hit = false
var health = max_health
var velocity = Vector2.ZERO

var player: Node2D = null # stores player reference while chasing
var is_chasing = false # true while actively chasing
var player_in_range = false # true while player is inside big detection area
var leash_timer = 0.0 # counts down after player leaves area
var speed #used to ensure physics works

signal killed

func _ready() -> void:
	health = max_health
	linear_velocity = Vector2(patrol_speed * direction, 0)
	lock_rotation = true

"""
func _process(delta: float) -> void:
	velocity.y += gravity * delta
	position += velocity * delta
"""

func _integrate_forces(state) -> void:
	var vel = state.linear_velocity

	if is_chasing and player != null:
		var to_player = player.global_position - global_position
		var dist = to_player.length()

		if dist > preferred_max_distance:
			vel = to_player.normalized() * chase_speed
		elif dist < preferred_min_distance:
			vel = -to_player.normalized() * backoff_speed
		else:
			vel = to_player.normalized() * (chase_speed * 0.4)

	else:
		vel.x = patrol_speed * direction
		vel.y = 0

	state.linear_velocity = vel
	
	
func _physics_process(delta: float) -> void:
	# flips sprite
	$AnimatedSprite2D.flip_h = linear_velocity.x < 0
	#linear_velocity.x = speed * direction

	# tilt upwards when chasing up, tilt downwards wen chasig down
	var target_rotation = 0.0

	if is_chasing:
		if linear_velocity.y < 0:
			target_rotation = -0.3
		elif linear_velocity.y > 0:
			target_rotation = 0.3
		else:
			target_rotation = 0.0

		# Reverse tilt when facing left
		if linear_velocity.x < 0:
			target_rotation *= -1

	rotation = lerp(rotation, target_rotation, tilt_lerp_speed)

	# if player left range, keep chasing for a bit, then stop
	if is_chasing and not player_in_range:
		leash_timer -= delta
		if leash_timer <= 0:
			stop_chasing()

func _on_mob_timer_timeout() -> void:
	pass
	
func _process(delta: float) -> void:
	#get player distance
	#queuefree if distance above threshold
	if player:
		if global_position.distance_to(player.global_position) > despawn_distance:
			queue_free()

"""
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
"""


# Small hit area for spear only.
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Trident"):
		if area.has_method("get_damage"):
			take_damage(area.get_damage(), area.global_position.x)
		else:
			take_damage(1, area.global_position.x)
		print("Malicious Mob touched by: ", area.name, " Trident=", area.is_in_group("Trident"))

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
	
func get_attack_knockback() -> float:
	return attack_knockback_strength


func get_score_value() -> int:
	return score_value
