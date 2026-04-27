extends Area2D

@export var speed: float = 300.0
@export var sink_speed: float = 90.0
@export var attack_duration: float = 0.2
@export var max_health: int = 5
@export var attack_knockback_strength: float = 100.0
@export var hurt_knockback_multiplier: float = 1.0
@export var hurt_cooldown: float = 1.5
@export var attack_cooldown: float = 0.3


signal hit
signal health_changed

var knockback_velocity = Vector2.ZERO
var knockback_timer = 0.0
var attack_cooldown_timer = 0.0
var can_take_damage = true
var health = max_health
var screen_size
var is_attacking = false
var attack_timer = 0.0
var alive = true
var is_hit = false
var facing_right = true
var game_started = false


@onready var sprite = $AnimatedSprite2D
@onready var trident = $Trident
@onready var left_hitbox = $Trident/LeftHitBox
@onready var right_hitbox = $Trident/RightHitBox
@onready var trident_start_pos = trident.position
@onready var player_swim = $PlayerSwim
@onready var player_attack = $PlayerAttack
@onready var player_hurt = $PlayerHurt
@onready var player_heartbeat = $PlayerHeartbeat


func _ready() -> void:
	screen_size = get_viewport_rect().size
	
	left_hitbox.disabled = true
	right_hitbox.disabled = true
	health = max_health
	health_changed.emit(health)

func _start() -> void:
	position = Vector2(50, 50)
	show()
	game_started = true
	$CollisionShape2D.disabled = false
	left_hitbox.disabled = true
	right_hitbox.disabled = true
	health = max_health
	alive = true
	can_take_damage = true
	is_attacking = false
	is_hit = false
	health_changed.emit(health)
	knockback_velocity = Vector2.ZERO
	knockback_timer = 0.0
	attack_cooldown_timer = 0.0

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
	if attack_cooldown_timer > 0:
		attack_cooldown_timer -= delta
	if velocity.x > 0:
		facing_right = true
		sprite.flip_h = true
	elif velocity.x < 0:
		facing_right = false
		sprite.flip_h = false

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		if not is_attacking:
			sprite.play("swim")
	else:
		if not is_attacking:
			sprite.play("default")	
		
	if not game_started:
		velocity.y = 0
	else:
		velocity.y += sink_speed
		
		
	var final_velocity = velocity

	if knockback_timer > 0:
		final_velocity += knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 6 * delta)
		knockback_timer -= delta

	position += final_velocity * delta
	
	# swimming logic 
	if not player_swim.playing:
		player_swim.play() # Keep it playing always
	
	if velocity.length() > 95:
		player_swim.volume_db = -2.0 # Louder when moving
	else:
		player_swim.volume_db = -18.0 # Quieter 'drift' bubbles when still

	position.y = clamp(position.y, 0, 8500)

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

	

	if Input.is_action_just_pressed("attack") and not is_attacking and attack_cooldown_timer <= 0:
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
	attack_cooldown_timer = attack_cooldown
	sprite.play("attack")
	player_attack.play() # this is when the player attacks 
	update_attack_hitbox_direction()

func end_attack() -> void:
	is_attacking = false
	sprite.play("default")
	left_hitbox.disabled = true
	right_hitbox.disabled = true
	
func get_attack_knockback() -> float:
	return attack_knockback_strength

func apply_knockback(from_x: float, strength: float) -> void:
	var direction = sign(global_position.x - from_x)
	if direction == 0:
		direction = 1
	knockback_velocity = Vector2(direction * strength * hurt_knockback_multiplier, -40)
	knockback_timer = 1.1
	
func take_damage(amount: int, hit_from_x: float, enemy_knockback: float) -> void:
	if not alive or not can_take_damage:
		return

	player_hurt.volume_db = 5.0
	player_hurt.pitch_scale = randf_range(0.8, 1.5)
	player_hurt.play()

	can_take_damage = false

	health -= amount
	health_changed.emit(health)
	
	if not player_heartbeat.playing:
		player_heartbeat.play()
		player_heartbeat.volume_db = -2.0 # Quiet start
		player_heartbeat.pitch_scale = 1.0 # Normal speed
	elif health == 1:
		player_heartbeat.volume_db = 2.0   # Loud danger
		player_heartbeat.pitch_scale = 1.4 # High speed/Panic!
	elif health <= 0:
		player_heartbeat.stop()
	show_hit_flash()
	apply_knockback(hit_from_x, enemy_knockback)

	var direction = sign(global_position.x - hit_from_x)
	if direction == 0:
		direction = 1

	

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
	game_started = false
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
	print("PLAYER TOUCHED AREA: ", area.name, " groups=", area.get_groups())
	
	if not alive:
		return

	if area == trident:
		return

	if not area.is_in_group("MaliciousMob"):
		return

	var damage := 1
	var enemy_knockback := 70.0

	if area.has_method("get_damage"):
		damage = area.get_damage()

	if area.has_method("get_attack_knockback"):
		enemy_knockback = area.get_attack_knockback()

	take_damage(damage, area.global_position.x, enemy_knockback)
	print("Player touched area: ", area.name, " MaliciousMob=", area.is_in_group("MalicousMob"))

func _on_body_entered(body: Node2D) -> void:
	if not alive:
		return

	if body.is_in_group("PassiveMob"):
		return

	if not body.has_method("get_damage"):
		return

	var damage : int = body.get_damage()
	var enemy_knockback := 70.0

	if body.has_method("get_attack_knockback"):
		enemy_knockback = body.get_attack_knockback()

	take_damage(damage, body.global_position.x, enemy_knockback)
