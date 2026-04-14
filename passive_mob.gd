extends RigidBody2D

@export var gravity = 0
@export var base_velocity = 180
@export var velocity_variability = 50
@export var max_distance := 1000.0
var player

signal killed

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_first_node_in_group("player")

func _process(delta):
	if player:
		if global_position.distance_to(player.global_position) > max_distance:
			queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("spear"):
		killed.emit()
		queue_free()
		
		
"""
func _on_visible_on_screen_notifier_2d_screen_exited() -> void: #makes them disapear off screen dont know if we want that
	queue_free() # Replace with function body.
"""
