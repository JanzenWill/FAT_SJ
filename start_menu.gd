extends CanvasLayer

signal start_game


func _ready() -> void:
	show()
	$UI/LeaderboardPanel.hide()
	



func _on_start_button_pressed() -> void:
	hide()
	start_game.emit()


func _on_leaderboard_button_pressed() -> void:
	$UI/TextureRect.hide()
	$UI/Title.hide()
	$UI/StartButton.hide()
	$UI/"Leaderboard Button".hide()

	show_leaderboard()
	$UI/LeaderboardPanel.show()


func _on_back_button_pressed() -> void:
	$UI/LeaderboardPanel.hide()

	$UI/TextureRect.show()
	$UI/Title.show()
	$UI/StartButton.show()
	$UI/"Leaderboard Button".show()


func show_leaderboard() -> void:
	var scores = Leaderboard.get_scores()
	var text = ""

	if scores.is_empty():
		text = "No scores yet."
	else:
		for i in range(scores.size()):
			var entry = scores[i]
			text += str(i + 1) + ". "
			text += str(entry["name"]) + " - "
			text += str(int(entry["score"])) + "\n"

	$UI/LeaderboardPanel/ScoresLabel.text = text
