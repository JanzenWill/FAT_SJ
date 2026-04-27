extends CanvasLayer

signal restart_game
signal save_score_requested(player_name)


func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()


func _on_message_timer_timeout() -> void:
	$Message.hide()


func _ready() -> void:
	$VBoxContainer/ScoreLabel.show()
	$VBoxContainer/NameInput.hide()
	$VBoxContainer/SaveScoreButton.hide()


func _new_game():
	$Message.text = "Avenge your Father!\n\nVanquish the malicious fish, while taking care not to harm the endangered fish."
	$Message.show()
	$VBoxContainer/NameInput.hide()
	$VBoxContainer/SaveScoreButton.hide()
	$VBoxContainer/NameInput.text = ""


func show_game_over():
	$Message.add_theme_font_size_override("font_size", 80)
	show_message("Game Over")
	await $MessageTimer.timeout
	await get_tree().create_timer(1.0).timeout
	$VBoxContainer/NameInput.show()
	$VBoxContainer/SaveScoreButton.show()
	$VBoxContainer/StartButton.show()


func _on_start_button_pressed() -> void:
	$VBoxContainer/StartButton.hide()
	$VBoxContainer/NameInput.hide()
	$VBoxContainer/SaveScoreButton.hide()		
	restart_game.emit()


func _on_save_score_button_pressed() -> void:
	var player_name = $VBoxContainer/NameInput.text.strip_edges()

	if player_name == "":
		player_name = "PLAYER"

	save_score_requested.emit(player_name)

	$VBoxContainer/NameInput.hide()
	$VBoxContainer/SaveScoreButton.hide()


func update_score(score):
	$VBoxContainer/ScoreLabel.text = "Score: " + str(score)


func update_health(health):
	$VBoxContainer/HBoxContainer/BlueHeartPixelArt1.visible = health >= 1
	$VBoxContainer/HBoxContainer/BlueHeartPixelArt2.visible = health >= 2
	$VBoxContainer/HBoxContainer/BlueHeartPixelArt3.visible = health >= 3
	$VBoxContainer/HBoxContainer/BlueHeartPixelArt4.visible = health >= 4
	$VBoxContainer/HBoxContainer/BlueHeartPixelArt5.visible = health >= 5


func flash_score_red() -> void:
	var label = $VBoxContainer/ScoreLabel
	label.modulate = Color(1, 0.2, 0.2)
	await get_tree().create_timer(0.2).timeout
	label.modulate = Color(1, 1, 1)
