extends RigidBody2D

@export var gravity = 0
@export var max_health = 3 # health
@export var damage = 1 # damage it gives
@export var knockback_strength = 300

@export var attack_knockback_strength: float = 1500

@export var patrol_speed = 100.0 # normal left/right swim speed
@export var chase_speed = 150.0 # faster speed while chasing player
@export var leash_time = 1.5 # how long it keeps chasing after player leaves range
@export var tilt_strength = 0.0018 # how much fish rotates based on movement
@export var tilt_lerp_speed = 0.18 # how quickly rotation catches up

var knockback_velocity = Vector2.ZERO
var knockback_timer = 0.0

var direction = 1 # patrol direction: 1 = right, -1 = left
var is_hit = false
var health = max_health
var velocity = Vector2.ZERO

var player: Node2D = null # stores player reference while chasing
var is_chasing = false # true while actively chasing
var player_in_range = false # true while player is inside big detection area
var leash_timer = 0.0 # counts down after player leaves area
var facing_left = false
var mouth_shape_offset_x := 0.0

signal killed

func _ready() -> void:
	health = max_health
	linear_velocity = Vector2(patrol_speed * direction, 0)
	lock_rotation = true
	mouth_shape_offset_x = abs($AttackArea/CollisionShape2D.position.x)

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
	if linear_velocity.x < -1:
		facing_left = true
	elif linear_velocity.x > 1:
		facing_left = false

	$AnimatedSprite2D.flip_h = facing_left

	if facing_left:
		$AttackArea/CollisionShape2D.position.x = -mouth_shape_offset_x
	else:
		$AttackArea/CollisionShape2D.position.x = mouth_shape_offset_x

	var target_rotation = 0.0

	if is_chasing:
		if linear_velocity.y < 0:
			target_rotation = -0.3
		elif linear_velocity.y > 0:
			target_rotation = 0.3
		else:
			target_rotation = 0.0

		if linear_velocity.x < 0:
			target_rotation *= -1

	rotation = lerp(rotation, target_rotation, tilt_lerp_speed)
	print("facing_left=", facing_left, " attack_x=", $AttackArea.position.x)


func _on_mob_timer_timeout() -> void:
	pass

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

# hit area for spear only.
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Trident"):
		if area.has_method("get_damage"):
			take_damage(area.get_damage(), area.global_position.x)
		else:
			take_damage(1, area.global_position.x)

		print("Swordfish hit by: ", area.name)



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

#func get_damage() -> int:
#	return damage

func show_hit_flash() -> void:
	if is_hit:
		return

	is_hit = true
	$AnimatedSprite2D.modulate = Color(1, 0.4, 0.4)
	await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.modulate = Color(1, 1, 1)
	is_hit = false
	
#func get_attack_knockback() -> float:
#	return attack_knockback_strength


func _on_detection_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		player = area
		player_in_range = true
		is_chasing = true
		leash_timer = leash_time


func _on_detection_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("player") and area == player:
		player_in_range = false
		leash_timer = leash_time
