extends Node

@export var passive_mob_scene: PackedScene
@export var malicious_mob_scene: PackedScene
@export var evil_mob_scene: PackedScene

var score = 0
var depth_level = 0
var depth_thresholds = [4000, 9000] #real thresholds tims inverse scroll rate #expand later

func _ready():
	$HUD/VBoxContainer/StartButton.hide()
	$HUD.restart_game.connect(_on_restart_game)
	$Player.health_changed.connect($HUD.update_health)
	$HUD/VBoxContainer/ScoreLabel.show()
	$HUD.update_score(score)
	$HUD.update_health($Player.health)
	
	
func _process(delta: float) -> void:
	check_depth()

func _on_passive_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var passive_mob = passive_mob_scene.instantiate()
	passive_mob.killed.connect(_on_killed_passive_mob)
	passive_mob.add_to_group("fish") #added to group of fish that are removed with restart

	var player = $Player
	
	#spawn just off screen horizontally
	var spawn_x = player.global_position.x + (1050)*[-1, 1].pick_random()
	#spawn within one screen length vertically of the player
	var spawn_y = player.global_position.y + (randf_range(0, 600) * [-1, 1].pick_random())
	
	#TODO: modify spawn_y if it's too high or too low

	# Set the mob's position to the random location.
	passive_mob.position = Vector2(spawn_x, spawn_y)
	passive_mob.direction = [-1, 1].pick_random()
	var speed = passive_mob.base_speed * (randf_range(1 - passive_mob.speed_variability_factor, 1 + passive_mob.speed_variability_factor))
	passive_mob.speed = speed
	passive_mob.linear_velocity = Vector2(speed * passive_mob.direction, 0)

	# Spawn the mob by adding it to the Main scene.
	add_child(passive_mob)


func check_depth() -> void:
	var player_y = $Player.global_position.y
	if player_y > depth_thresholds[depth_level] and depth_level < (depth_thresholds.size()-1):
		depth_level += 1
		increase_difficulty()
		
	elif player_y < depth_thresholds[depth_level - 1] and depth_level > 0:
		depth_level -= 1
		decrease_difficulty()
		
		
func increase_difficulty() -> void:
	$MaliciousMobTimer.wait_time *= 0.6
	$PassiveMobTimer.wait_time *= 1.2
	$Player.speed *= 0.8
	$EvilMobTimer.start()
	#print("difficulty increase ", depth_level)
	
func decrease_difficulty() -> void:
	$MaliciousMobTimer.wait_time  *= 1.667
	$PassiveMobTimer.wait_time *= 0.8334
	$Player.speed *= 1.25
	$EvilMobTimer.stop()
	#print("difficulty decrease ", depth_level)
	

func _on_malicious_mob_timer_timeout() -> void:
		# Create a new instance of the Mob scene.
	var malicious_mob = malicious_mob_scene.instantiate()
	malicious_mob.killed.connect(_on_killed_malicious_mob)
	malicious_mob.add_to_group("fish") #added to group of fish that are removed with restart

	var player = $Player
	
	#spawn just off screen horizontally
	var spawn_x = player.global_position.x + (1050)*[-1, 1].pick_random()
	#spawn within one screen length vertically of the player
	var spawn_y = player.global_position.y + (randf_range(0, 600) * [-1, 1].pick_random())
	
	#TODO: modify spawn_y if it's too high or too low

	# Set the mob's position to the random location.
	malicious_mob.position = Vector2(spawn_x, spawn_y)
	malicious_mob.direction = [-1, 1].pick_random()
	var speed = malicious_mob.patrol_speed * (randf_range(-malicious_mob.speed_variability_factor, malicious_mob.speed_variability_factor))
	malicious_mob.linear_velocity = Vector2(speed * malicious_mob.direction, 0)

	# Spawn the mob by adding it to the Main scene.
	add_child(malicious_mob)


func _on_player_hit() -> void:
	#print("Player hit by malicious mob")
	$PassiveMobTimer.stop()
	$MaliciousMobTimer.stop()
	$HUD.show_game_over()
	#$Music.stop()
	#$DeathSound.play()
	
func _on_restart_game():
	score = 0
	$HUD.update_score(score)
	$PassiveMobTimer.start()
	$Player.health = 3
	$HUD.update_health($Player.health)
	$MaliciousMobTimer.start()
	$Player._start()
	$Player.show()
	$Player/CollisionShape2D.set("disabled", false)
	$Player.alive = true
	clear_all_fish()
	
func _on_killed_passive_mob():
	if score > 0:
		score -= 1
	$HUD.update_score(score)
	

func _on_killed_malicious_mob():
	score += 1
	$HUD.update_score(score)
	
	
func clear_all_fish() -> void: #clears all fish
	get_tree().call_group("fish", "queue_free")
	
	


func _on_evil_mob_timer_timeout() -> void:
	#print("evilmobtimer timeout")
	if depth_level < 1:
		pass
	else:
		#print("Evil Mob Spawn Activated!")
		var evil_mob = evil_mob_scene.instantiate()
		evil_mob.add_to_group("fish") #added to group of fish that are removed with restart
		
		#evil_mob.killed.connect(_on_killed_malicious_mob)

		var camera = $Player/Camera2D
		#var viewport_size = get_viewport().size
		
		var spawn_x = camera.global_position.x + (700*[-1, 1].pick_random())
		var spawn_y = camera.global_position.y + (400 * [-1, 1].pick_random())
		

		# Set the mob's position to the random location.
		evil_mob.position = Vector2(spawn_x, spawn_y)
		evil_mob.direction = [-1, 1].pick_random()

		# Spawn the mob by adding it to the Main scene.
		add_child(evil_mob)
		
