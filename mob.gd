extends RigidBody2D

@export var gravity = 900
var velocity = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity.y += gravity * delta
	position += velocity * delta


func _on_mob_timer_timeout() -> void:
	pass # Replace with function body.
