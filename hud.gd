extends CanvasLayer

signal restart_game

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func _on_message_timer_timeout() -> void:
	$Message.hide()

func _ready() -> void:
	$VBoxContainer/ScoreLabel.show()

func _new_game():
	$Message.text = "Avenge your Father!\n\nVanquish the malicious fish, while taking care not to harm the endangered fish."
	$Message.show()

func show_game_over():
	$Message.add_theme_font_size_override("font_size", 80)
	show_message("Game Over")
	await $MessageTimer.timeout
	await get_tree().create_timer(1.0).timeout
	$VBoxContainer/StartButton.show()

func _on_start_button_pressed() -> void:
	$VBoxContainer/StartButton.hide()
	restart_game.emit()

func update_score(score):
	$VBoxContainer/ScoreLabel.text = "Score: " + str(score)

func update_health(health):
	$VBoxContainer/HBoxContainer/BlueHeartPixelArt1.visible = health >= 1
	$VBoxContainer/HBoxContainer/BlueHeartPixelArt2.visible = health >= 2
	$VBoxContainer/HBoxContainer/BlueHeartPixelArt3.visible = health >= 3
