extends Node

@export var passive_mob_scene: PackedScene
@export var malicious_mob_scene: PackedScene

var score = 0

func _ready():
	$HUD/StartButton.hide()
	$HUD.restart_game.connect(_on_restart_game)
	$HUD/ScoreLabel.show()
	


func _on_passive_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var passive_mob = passive_mob_scene.instantiate()
	passive_mob.killed.connect(_on_killed_passive_mob)
	passive_mob.add_to_group("fish") #added to group of fish that are removed with restart

	var camera = $Player/Camera2D
	var viewport_size = get_viewport().size
	
	var spawn_x = camera.global_position.x + (viewport_size.x + 100)*[-1, 1].pick_random()
	var spawn_y = randf_range(50, viewport_size.y - 50)
	

	# Set the mob's position to the random location.
	passive_mob.position = Vector2(spawn_x, spawn_y)
	passive_mob.linear_velocity = Vector2(180 * [-1, 1].pick_random(), 0.0)

	# Spawn the mob by adding it to the Main scene.
	add_child(passive_mob)
	"""
#hopefully sets the mob direction either right or left	
	var direction = [0, PI][randi() % 2]

	# Choose the velocity for the mob.
	passive_mob.linear_velocity = velocity.rotated(direction)
"""


func _on_malicious_mob_timer_timeout() -> void:
	# Create a new instance of the Mob scene.
	var malicious_mob = malicious_mob_scene.instantiate()
	malicious_mob.add_to_group("fish") #added to group of fish that are removed with restart
	
	malicious_mob.killed.connect(_on_killed_malicious_mob)

	var camera = $Player/Camera2D
	var viewport_size = get_viewport().size
	
	var spawn_x = camera.global_position.x + (viewport_size.x + 100)*[-1, 1].pick_random()
	var spawn_y = randf_range(50, viewport_size.y - 50)
	

	# Set the mob's position to the random location.
	malicious_mob.position = Vector2(spawn_x, spawn_y)
	malicious_mob.linear_velocity = Vector2(180 * [-1, 1].pick_random(), 0.0)

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
	$MaliciousMobTimer.start()
	$Player.show()
	$Player/CollisionShape2D.set("disabled", false)
	$Player.alive = true
	clear_all_fish()
	
func _on_killed_passive_mob():
	if score > 0:
		score -= 1
	$HUD.update_score(score)
	print(score)

func _on_killed_malicious_mob():
	score += 1
	$HUD.update_score(score)
	print(score)
	
func clear_all_fish() -> void: #clears all fish
	get_tree().call_group("fish", "queue_free")
	
	
