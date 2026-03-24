extends Node

@export var passive_mob_scene: PackedScene
@export var malicious_mob_scene: PackedScene


func _on_passive_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var passive_mob = passive_mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to the random location.
	passive_mob.position = mob_spawn_location.position

#hopefully sets the mob direction either right or left	
	var direction = [0, PI][randi() % 2]

	# Choose the velocity for the mob.
	var velocity = Vector2(160, 0.0)
	passive_mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(passive_mob)


func _on_malicious_mob_timer_timeout() -> void:
	# Create a new instance of the Mob scene.
	var malicious_mob = malicious_mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to the random location.
	malicious_mob.position = mob_spawn_location.position

#hopefully sets the mob direction either right or left	
	var direction = [0, PI][randi() % 2]

	# Choose the velocity for the mob.
	var velocity = Vector2(160, 0.0)
	malicious_mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(malicious_mob)
