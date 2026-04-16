extends Node

@export var passive_mob_scene: PackedScene
@export var passive_mob2_scene: PackedScene
@export var malicious_mob_scene: PackedScene
@export var evil_mob_scene: PackedScene
@export var shark_boss_scene: PackedScene

var score = 0
var depth_level = 0
var depth_thresholds = [4000, 9000] #real thresholds tims inverse scroll rate #expand later

var shark_spawned = false
var shark_alive = false
var shark_boss = null

func _ready():
	$HUD.hide()
	$StartMenu.show()
	$StartMenu.start_game.connect(_on_start_menu_start_game)
	$HUD.restart_game.connect(_on_restart_game)
	$Player.hit.connect(_on_player_hit)
	$Player.health_changed.connect($HUD.update_health)

func _on_start_menu_start_game() -> void:
	$StartMenu.hide()
	$Player._start()
	$HUD.show()
	$HUD/VBoxContainer/StartButton.hide()
	$HUD._new_game()
	
func _process(delta: float) -> void:
	check_depth()

func _on_passive_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var passive_mob = passive_mob_scene.instantiate()
	passive_mob.killed.connect(_on_killed_passive_mob)
	passive_mob.add_to_group("fish") #added to group of fish that are removed with restart

	var camera = $Player/Camera2D
	var viewport_size = get_viewport().size
	
	var spawn_x = camera.global_position.x + (viewport_size.x + 100)*[-1, 1].pick_random()
	var spawn_y = camera.global_position.y + (100 * [-1, 1].pick_random())

	# Set the mob's position to the random location.
	passive_mob.position = Vector2(spawn_x, spawn_y)
	passive_mob.direction = [-1, 1].pick_random()

	# Spawn the mob by adding it to the Main scene.
	add_child(passive_mob)
	


func _on_passive_mob_2_timer_timeout():
	# Create a new instance of the Mob scene.
	var passive_mob = passive_mob2_scene.instantiate()
	passive_mob.killed.connect(_on_killed_passive_mob)
	passive_mob.add_to_group("fish") #added to group of fish that are removed with restart

	var camera = $Player/Camera2D
	var viewport_size = get_viewport().size
	
	var spawn_x = camera.global_position.x + (viewport_size.x + 200)*[-1, 1].pick_random()
	var spawn_y = camera.global_position.y + (200 * [-1, 1].pick_random())

	# Set the mob's position to the random location.
	passive_mob.position = Vector2(spawn_x, spawn_y)
	passive_mob.direction = [-1, 1].pick_random()

	# Spawn the mob by adding it to the Main scene.
	add_child(passive_mob)
	"""
#hopefully sets the mob direction either right or left	
	var direction = [0, PI][randi() % 2]

	# Choose the velocity for the mob.
	passive_mob.linear_velocity = velocity.rotated(direction)
"""
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
	malicious_mob.add_to_group("fish") #added to group of fish that are removed with restart
	
	malicious_mob.killed.connect(_on_killed_malicious_mob)

	var camera = $Player/Camera2D
	var viewport_size = get_viewport().size
	
	var spawn_x = camera.global_position.x + (viewport_size.x + 100)*[-1, 1].pick_random()
	var spawn_y = camera.global_position.y + (100 * [-1, 1].pick_random())
	

	# Set the mob's position to the random location.
	malicious_mob.position = Vector2(spawn_x, spawn_y)
	malicious_mob.direction = [-1, 1].pick_random()

	# Spawn the mob by adding it to the Main scene.
	add_child(malicious_mob)


func _on_player_hit() -> void:
	#print("Player hit by malicious mob")
	$PassiveMobTimer.stop()
	$MaliciousMobTimer.stop()
	clear_all_fish()
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
	shark_spawned = false
	shark_alive = false
	clear_all_fish()
	
func _on_killed_passive_mob():
	if score > 0:
		score -= 1
	$HUD.update_score(score)
	

func _on_killed_malicious_mob():
	score += 1
	$HUD.update_score(score)
	
	if score == 5 and not shark_spawned and not shark_alive:
		spawn_shark_boss()
	
func clear_all_fish() -> void: #clears all fish
	get_tree().call_group("fish", "queue_free")
	
	


func _on_evil_mob_timer_timeout() -> void:
	#print("evilmobtimer timeout")
	if depth_level < 1:
		pass
	else:
		if not shark_alive:
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
		else:
			pass
		

	
	
func spawn_shark_boss() -> void:
	if shark_spawned or shark_alive:
		return
	
	clear_all_fish()
	$PassiveMobTimer.stop()
	$PassiveMob2Timer.stop()
	$MaliciousMobTimer.stop()
	$EvilMobTimer.stop()
	
	for i in range(3):
		$SharkBossMessages/SharkBossMessage.visible = true
		await get_tree().create_timer(0.6).timeout

		$SharkBossMessages/SharkBossMessage.visible = false
		await get_tree().create_timer(0.6).timeout

	
	
	shark_boss = shark_boss_scene.instantiate()
	shark_boss.add_to_group("fish")
	shark_boss.killed.connect(_on_shark_boss_killed)
	
	

	var camera = $Player/Camera2D
	var spawn_x = camera.global_position.x + 1000 * [-1, 1].pick_random()
	var spawn_y = camera.global_position.y

	shark_boss.position = Vector2(spawn_x, spawn_y)
	shark_boss.direction = [-1, 1].pick_random()
	add_child(shark_boss)

	shark_spawned = true
	shark_alive = true
	
	
	
func _on_shark_boss_killed() -> void:
	shark_alive = false
	shark_boss = null
	
	for i in range(3):
		$SharkBossMessages/SharkEnd.visible = true
		await get_tree().create_timer(0.6).timeout

		$SharkBossMessages/SharkEnd.visible = false
		await get_tree().create_timer(0.6).timeout
	
	score += 50
	$HUD.update_score(score)

	$PassiveMobTimer.start()
	$PassiveMob2Timer.start()
	$MaliciousMobTimer.start()

	if depth_level >= 1:
		$EvilMobTimer.start()
