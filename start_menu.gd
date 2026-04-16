extends CanvasLayer

signal start_game

func _ready() -> void:
	show()
	

func _on_start_button_pressed() -> void:
	hide()
	start_game.emit()

func _on_leaderboard_button_pressed() -> void:
	# add leaderboard logic later
	pass
