extends Node
var playa
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
	var playa = $Player
	var spawn_x = playa.global_position.x+((1000)*[-1, 1].pick_random())
	var player_y = playa.global_position.y
	var spawn_y = randf_range(player_y-350, player_y+350)
	#Limit y spawn to background 
	if spawn_y > 3500:
		spawn_y == 3500
	elif spawn_y < 100:
		spawn_y == 100
	
	passive_mob.position = Vector2(spawn_x, spawn_y)
	
	passive_mob.linear_velocity = Vector2(passive_mob.base_velocity * [-1, 1].pick_random() + (randf_range(-passive_mob.velocity_variability, passive_mob.velocity_variability)), 0)

	# Spawn the mob by adding it to the Main scene.
	add_child(passive_mob)



func _on_malicious_mob_timer_timeout() -> void:
	# Create a new instance of the Mob scene.
	var malicious_mob = malicious_mob_scene.instantiate()
	var playa = $Player
	var spawn_x = playa.global_position.x+((1000)*[-1, 1].pick_random())
	var player_y = playa.global_position.y
	var spawn_y = randf_range(player_y-350, player_y+350)
	#Limit y spawn to background 
	if spawn_y > 3500:
		spawn_y == 3500
	elif spawn_y < 100:
		spawn_y == 100
	
	malicious_mob.position = Vector2(spawn_x, spawn_y)
	
	malicious_mob.linear_velocity = Vector2(malicious_mob.base_velocity * [-1, 1].pick_random() + (randf_range(-malicious_mob.velocity_variability, malicious_mob.velocity_variability)), 0)

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
	
func _on_killed_passive_mob():
	score += 1
	$HUD.update_score(score)
	
	
