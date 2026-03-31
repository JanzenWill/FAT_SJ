extends Node

@export var passive_mob_scene: PackedScene
@export var malicious_mob_scene: PackedScene

var score = 0
var depth_level = 0
var depth_thresholds = [1750] #expand later

func _ready():
	$HUD/StartButton.hide()
	$HUD.restart_game.connect(_on_restart_game)
	$Player.health_changed.connect($HUD.update_health)
	$HUD/ScoreLabel.show()
	$HUD.update_score(score)
	$HUD.update_health($Player.health)
	
	
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
	"""
#hopefully sets the mob direction either right or left	
	var direction = [0, PI][randi() % 2]

	# Choose the velocity for the mob.
	passive_mob.linear_velocity = velocity.rotated(direction)
"""
func check_depth() -> void:
	var player_y = $Player.global_position.x
	if depth_level < depth_thresholds.size() and player_y > depth_thresholds[depth_level]:
		depth_level += 1
		increase_difficulty()
		
func increase_difficulty() -> void:
	$MaliciousMobTimer.wait_time *= 0.6
	$PassiveMobTimer.wait_time *= 1.2

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
	$HUD.show_game_over()
	#$Music.stop()
	#$DeathSound.play()
	
func _on_restart_game():
	score = 0
	$HUD.update_score(score)
	$PassiveMobTimer.start()
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
	
	
