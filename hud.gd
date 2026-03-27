extends CanvasLayer

signal restart_game

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func _on_message_timer_timeout() -> void:
	$Message.hide()

func _ready() -> void:
	$ScoreLabel.show()
'''
func _process(delta: float) -> void:
	pass
'''

func _new_game():
	$Message.text = "Avenge your Father!

Vanquish the malicious fish, while taking care not to harm the endangered fish. "
	$Message.show()
	

func show_game_over():
	show_message("Game Over")
	await $MessageTimer.timeout	
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()


func _on_start_button_pressed() -> void:
	$StartButton.hide()
	restart_game.emit()
	
func update_score(score):
	$ScoreLabel.text = "Score: " + str(score)

func update_health(health):
	$HealthLabel.text = "Health: " + str(health)
