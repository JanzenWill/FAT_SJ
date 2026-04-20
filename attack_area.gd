extends Area2D

@export var damage: int = 1
@export var attack_knockback_strength: float = 1500.0

func get_damage() -> int:
	return damage

func get_attack_knockback() -> float:
	return attack_knockback_strength
