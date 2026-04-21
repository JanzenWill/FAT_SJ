extends RigidBody2D

@export var gravity = 0
@export var max_health = 1 # health
@export var damage = 0 # damage it gives
@export var knockback_strength = 200
@export var base_speed = 130
@export var direction = 1
@export var speed_variability_factor = 0.15
@export var max_distance = 2500
var health = max_health
var is_hit = false
var player
var speed #used to fix physics issue

signal killed

func _ready() -> void:
	#get player based on tree
	health = max_health
	rotation = 0.0
	linear_velocity = Vector2(base_speed * randf_range(0, 0.15) * direction, 0)
	lock_rotation = true
	player = get_tree().get_first_node_in_group("player")



func _on_mob_timer_timeout() -> void:
	pass
	
	
func _process(delta: float) -> void:
	#get player distance
	#queuefree if distance above threshold
	if player:
		if global_position.distance_to(player.global_position) > max_distance:
			queue_free()
	print(linear_velocity.x)

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("Fish touched by: ", area.name, " Trident=", area.is_in_group("Trident"))
	if area.is_in_group("Trident"):
		if area.has_method("get_damage"):
			take_damage(area.get_damage(), area.global_position.x)
		else:
			take_damage(1, area.global_position.x)
	

func _physics_process(_delta: float) -> void:
	$AnimatedSprite2D.flip_h = linear_velocity.x < 0
	linear_velocity.x = speed * direction


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
