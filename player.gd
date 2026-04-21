extends Area2D

@export var speed: float = 250
@export var sink_speed: float = 90.0
@export var attack_duration: float = 0.2
@export var max_health: int = 3
@export var knockback_strength: float = 70.0
@export var hurt_cooldown: float = 1.5

signal hit
signal health_changed

var can_take_damage = true
var health = max_health
var screen_size
var is_attacking = false
var attack_timer = 0.0
var alive = true
var is_hit = false
var facing_right = true

@onready var sprite = $AnimatedSprite2D
@onready var trident = $Trident
@onready var left_hitbox = $Trident/LeftHitBox
@onready var right_hitbox = $Trident/RightHitBox
@onready var trident_start_pos = trident.position
@onready var player_swim = $PlayerSwim
@onready var player_attack = $PlayerAttack
@onready var player_hurt = $PlayerHurt


func _ready() -> void:
	screen_size = get_viewport_rect().size


	left_hitbox.disabled = true
	right_hitbox.disabled = true
	health = max_health
	health_changed.emit(health)

func _start() -> void:
	position = Vector2(50, 50)
	show()
	$CollisionShape2D.disabled = false
	left_hitbox.disabled = true
	right_hitbox.disabled = true
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
		facing_right = true
		sprite.flip_h = true
	elif velocity.x < 0:
		facing_right = false
		sprite.flip_h = false

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		if not is_attacking:
			sprite.play("default")
		else:
			if not is_attacking:
				sprite.play("default")	
			
	velocity.y += sink_speed
	position += velocity * delta
	
	# swimming logic 
	if not player_swim.playing:
		player_swim.play() # Keep it playing always
	
	if velocity.length() > 95:
		player_swim.volume_db = -2.0 # Louder when moving
	else:
		player_swim.volume_db = -18.0 # Quieter 'drift' bubbles when still

	position.y = clamp(position.y, 0, 8000)

	var target_rotation = 0.0

	if velocity.y < -5:
		target_rotation = -0.25   # swimming up
	elif velocity.y > 5:
		target_rotation = 0.25    # swimming down
	else:
		target_rotation = 0.0

	# Fix rotation direction depending on which way player faces
	if not facing_right:
		target_rotation *= -1

	rotation = lerp(rotation, target_rotation, 0.1)

	

	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()

	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			end_attack()

func update_attack_hitbox_direction() -> void:
	if facing_right:
		trident.position = Vector2(abs(trident_start_pos.x), trident_start_pos.y)
		right_hitbox.disabled = not is_attacking
		left_hitbox.disabled = true
	else:
		trident.position = Vector2(-abs(trident_start_pos.x), trident_start_pos.y)
		right_hitbox.disabled = true
		left_hitbox.disabled = not is_attacking

func start_attack() -> void:
	is_attacking = true
	attack_timer = attack_duration
	sprite.play("attack")
	player_attack.play() # this is when the player attacks 
	update_attack_hitbox_direction()

func end_attack() -> void:
	is_attacking = false
	sprite.play("default")
	left_hitbox.disabled = true
	right_hitbox.disabled = true

func take_damage(amount: int, hit_from_x: float) -> void:
	if not alive or not can_take_damage:
		return

	player_hurt.volume_db = 5.0
	player_hurt.pitch_scale = randf_range(0.8, 1.5)
	player_hurt.play()
	
	can_take_damage = false
	player_hurt.play() # this is when the player is hurt or attacked

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
	player_swim.stop() # swimming sound stops when the player dies
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

	if area == trident:
		return

	if not area.is_in_group("enemy_hitbox"):
		return

	var damage := 1
	if area.has_method("get_damage"):
		damage = area.get_damage()

	take_damage(damage, area.global_position.x)
	print("Player touched area: ", area.name, " enemy_hitbox=", area.is_in_group("enemy_hitbox"))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("PassiveMob"):
		return

	if not body.is_in_group("MaliciousMob"):
		return
