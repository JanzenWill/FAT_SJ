
extends Control

@onready var hud = $"../HUD"
@onready var player = $"../Player"

func _ready() -> void:
	hud.hide()   


func _on_start_button_pressed() -> void:
	hide()       
	hud.show()    
	player.start()   
	hud._new_game()  

func _on_button_pressed() -> void:
	pass # Replace with function body.
