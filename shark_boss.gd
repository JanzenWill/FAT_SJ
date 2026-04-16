extends RigidBody2D

@export var gravity = 0
@export var max_health = 8 # health
@export var damage = 1 # damage it gives
@export var attack_knockback_strength: float = 3000.0
@export var hurt_knockback_multiplier: float = 10.0

@export var patrol_speed = 150.0 # normal left/right swim speed
@export var chase_speed = 230.0 # faster speed while chasing player
#@export var tilt_strength = 0.00001 # how much fish rotates based on movement
#@export var tilt_lerp_speed = 0.08 # how quickly rotation catches up

var knockback_velocity = Vector2.ZERO
var knockback_timer = 0.0

var direction = 1 # patrol direction: 1 = right, -1 = left
var is_hit = false
var health = max_health
var velocity = Vector2.ZERO

var player: Node2D = null # stores player reference while chasing
var is_chasing = false # true while actively chasing
var player_in_range = false # true while player is inside big detection area
var facing_left = false

signal killed

func _ready() -> void:
	health = max_health
	linear_velocity = Vector2(patrol_speed * direction, 0)
	lock_rotation = true
	$AnimatedSprite2D.play("default")

"""
func _process(delta: float) -> void:
	velocity.y += gravity * delta
	position += velocity * delta
"""

func _integrate_forces(state) -> void:
	
	if knockback_timer > 0:
		knockback_timer -= get_physics_process_delta_time()
		state.linear_velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.12)
		return

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

	if vel.x < 0:
		facing_left = true
	elif vel.x > 0:
		facing_left = false 
		
	state.linear_velocity = vel

func _physics_process(delta: float) -> void:
	# flips sprite
	$AnimatedSprite2D.flip_h = facing_left

	# tilt upwards when chasing up, tilt downwards wen chasig down
	#var target_rotation = 0.0

	#if is_chasing:
		#if linear_velocity.y < 0:
			#target_rotation = -0.3
		#elif linear_velocity.y > 0:
			#target_rotation = 0.3
		#else:
			#target_rotation = 0.0
#
		## Reverse tilt when facing left
		#if linear_velocity.x < 0:
			#target_rotation *= -1

	#rotation = lerp(rotation, target_rotation, tilt_lerp_speed)



func _on_mob_timer_timeout() -> void:
	pass

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

# Small hit area for spear only.
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Trident"):
		var damage: int = 1
		var attacker_knockback: float = 70.0

		if area.has_method("get_damage"):
			damage = area.get_damage()

		if area.has_method("get_attack_knockback"):
			attacker_knockback = area.get_attack_knockback()

		take_damage(damage, area.global_position.x, attacker_knockback)
		print("Shark touched by: ", area.name, " Trident=", area.is_in_group("Trident"))

# Big detection area for player aggro/chasing.
func _on_detection_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		player = area
		player_in_range = true
		is_chasing = true
		



	# Pick patrol direction based on last horizontal movement,
	# so it keeps swimming naturally instead of snapping weirdly.
	if linear_velocity.x > 0:
		direction = 1
	elif linear_velocity.x < 0:
		direction = -1

	linear_velocity = Vector2(patrol_speed * direction, 0)

func apply_knockback(from_x: float, strength: float) -> void:
	var knockback_direction = sign(global_position.x - from_x)
	if knockback_direction == 0:
		knockback_direction = 1

	knockback_velocity = Vector2(knockback_direction * strength, -30)
	knockback_timer = 0.2

func take_damage(amount: int, hit_from_x: float, attacker_knockback: float) -> void:
	health -= amount

	if health <= 0:
		die()
		return

	show_hit_flash()
	apply_knockback(hit_from_x, attacker_knockback)
		
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
