extends Area2D

@export var speed = 400
@export var sink_speed = 40
@export var attack_duration = 0.2
@export var attack_angle = 0.8
@export var attack_thrust_distance = 15
@export var max_health = 3
@export var knockback_strength = 70
@export var hurt_cooldown = 1.5

signal hit
signal health_changed

var can_take_damage = true
var health = max_health
var screen_size
var is_attacking = false
var attack_timer = 0.0
var arm_rest_rotation = 0.0
var spear_rest_position = Vector2.ZERO
var alive = true
var is_hit = false

func _ready() -> void:
	screen_size = get_viewport_rect().size
	arm_rest_rotation = $ArmPivot.rotation
	spear_rest_position = $ArmPivot/Spear.position

	$ArmPivot/Spear/SpearHitbox/CollisionShape2D.disabled = true

	health = max_health
	health_changed.emit(health)

func _start() -> void:
	position = Vector2(50, 50)
	show()
	$CollisionShape2D.disabled = false
	$ArmPivot/Spear/SpearHitbox/CollisionShape2D.disabled = true
	health = max_health
	alive = true
	can_take_damage = true
	is_attacking = false
	is_hit = false
	health_changed.emit(health)

func _process(delta: float) -> void:
	if not alive:
		return

	var velocity = Vector2.ZERO

	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = true
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = false

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

	velocity.y += sink_speed
	position += velocity * delta

	position.y = clamp(position.y, 0, (3100 * (1 / 0.2)) - 300)

	var target_rotation = clamp(velocity.x * 0.020, -0.7, 0.7)
	rotation = lerp(rotation, target_rotation, 0.1)

	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()

	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			end_attack()

func start_attack() -> void:
	is_attacking = true
	attack_timer = attack_duration
	$ArmPivot.rotation = arm_rest_rotation - attack_angle
	$ArmPivot/Spear.position = spear_rest_position + Vector2(attack_thrust_distance, 0)
	$ArmPivot/Spear/SpearHitbox/CollisionShape2D.disabled = false

func end_attack() -> void:
	is_attacking = false
	$ArmPivot.rotation = arm_rest_rotation
	$ArmPivot/Spear.position = spear_rest_position
	$ArmPivot/Spear/SpearHitbox/CollisionShape2D.disabled = true

func take_damage(amount: int, hit_from_x: float) -> void:
	if not alive or not can_take_damage:
		return

	can_take_damage = false

	health -= amount
	health_changed.emit(health)
	show_hit_flash()

	var direction = sign(global_position.x - hit_from_x)
	if direction == 0:
		direction = 1

	position.x += direction * knockback_strength

	if health <= 0:
		die()
		return

	await get_tree().create_timer(hurt_cooldown).timeout
	can_take_damage = true

func die() -> void:
	hide()
	$CollisionShape2D.set_deferred("disabled", true)
	alive = false
	hit.emit()

func show_hit_flash() -> void:
	if is_hit:
		return

	is_hit = true
	$AnimatedSprite2D.modulate = Color(1, 0.4, 0.4)
	await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.modulate = Color(1, 1, 1)
	is_hit = false

func _on_area_entered(area: Area2D) -> void:
	if not alive:
		return

	if area == $ArmPivot/Spear/SpearHitbox:
		return

	if not area.is_in_group("enemy_hitbox"):
		return

	print("Player touched enemy area:", area.name)

	var damage = 1
	if area.has_method("get_damage"):
		damage = area.get_damage()

	take_damage(damage, area.global_position.x)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("MaliciousMob"):
		return

	if body.has_method("get_damage"):
		take_damage(body.get_damage(), body.global_position.x)
	else:
		take_damage(1, body.global_position.x)
