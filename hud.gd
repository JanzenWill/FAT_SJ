extends CanvasLayer

signal restart_game
signal save_score_requested(player_name)
signal pause_game

signal home_requested


func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()


func _on_message_timer_timeout() -> void:
	$Message.hide()


func _ready() -> void:
	$ScoreLabel.show()
	$NameInput.hide()
	$SaveScoreButton.hide()
	$HomeButton.hide()
	$HighScoreMessage.hide()
	



func _new_game():
	$Message.add_theme_font_size_override("font_size", 50)
	$Message.add_theme_color_override("font_color", Color.YELLOW)
	$Message.text = "Avenge your Father!\n\nVanquish the malicious fish, while taking care not to harm the endangered fish."
	$Message.show()
	$NameInput.hide()
	$SaveScoreButton.hide()
	$HighScoreMessage.hide()
	$PauseButton.show()
	$NameInput.text = ""
	$HomeButton.hide()


func show_game_over(final_score: int):
	$Message.add_theme_font_size_override("font_size", 100)
	$Message.add_theme_color_override("font_color", Color.RED)
	$PauseButton.hide()
	show_message("Game Over")
	await $MessageTimer.timeout
	await get_tree().create_timer(1.0).timeout
	$HomeButton.show()
	$StartButton.show()
	if Leaderboard.qualifies_for_leaderboard(final_score):
		$NameInput.show()
		$SaveScoreButton.show()
		$HighScoreMessage.show()
		


func _on_start_button_pressed() -> void:
	$StartButton.hide()
	$NameInput.hide()
	$PauseButton.show()
	$SaveScoreButton.hide()		
	$HomeButton.hide()
	$HighScoreMessage.hide()
	restart_game.emit()


func _on_save_score_button_pressed() -> void:
	var player_name = $NameInput.text.strip_edges()

	if player_name == "":
		player_name = "PLAYER"

	save_score_requested.emit(player_name)

	$NameInput.hide()
	$NameInput.text = "" 
	$SaveScoreButton.hide()


func update_score(score):
	$ScoreLabel.text = "Score: " + str(score)


func update_health(health):
	$HBoxContainer/BlueHeartPixelArt1.visible = health >= 1
	$HBoxContainer/BlueHeartPixelArt2.visible = health >= 2
	$HBoxContainer/BlueHeartPixelArt3.visible = health >= 3
	$HBoxContainer/BlueHeartPixelArt4.visible = health >= 4
	$HBoxContainer/BlueHeartPixelArt5.visible = health >= 5


func flash_score_red() -> void:
	var label = $ScoreLabel
	label.modulate = Color(1, 0.2, 0.2)
	await get_tree().create_timer(0.2).timeout
	label.modulate = Color(1, 1, 1)


func _on_pause_button_pressed() -> void:
	if $PauseButton.text == "Pause":
		$PauseButton.text = "Resume"
	else:
		$PauseButton.text = "Pause"
	pause_game.emit()
func _on_home_button_pressed() -> void:
	home_requested.emit()
