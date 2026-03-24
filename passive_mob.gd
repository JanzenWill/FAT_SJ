extends RigidBody2D

@export var gravity = 900
var velocity = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	velocity.y += gravity * delta
#	position += velocity * delta


func _on_mob_timer_timeout() -> void:
	pass # Replace with function body.


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("spear"):
		queue_free()


#func _on_visible_on_screen_notifier_2d_screen_exited() -> void: makes them disapear off screen dont know if we want that
	#queue_free() # Replace with function body.
