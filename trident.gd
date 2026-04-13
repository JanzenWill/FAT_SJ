extends Area2D

@export var damage: int = 1

func get_damage() -> int:
	return damage

func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("enemy_hitbox"):
		return
	if not area.is_in_group("PassiveMob") and not area.is_in_group("MaliciousMob"):
		return
	var target := area.get_parent()
	if target != null and target.has_method("take_damage"):
		target.take_damage(damage, global_position.x)
