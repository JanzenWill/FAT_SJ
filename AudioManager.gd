extends Node

var music_player : AudioStreamPlayer

func _ready():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)

func play_music(path: String):
	# 1. Check if the player is already playing this exact file path
	if music_player.stream and music_player.stream.resource_path == path:
		return 

	# 2. If it's a NEW song, load it and play it
	var stream = load(path)
	if stream == null:
		print("ERROR: Could not find file at ", path)
		return
		


	print("AudioManager switching to: ", path)
	music_player.stream = stream
	music_player.play()
