extends Node2D

@export var bounce_power: float

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.velocity.y >= 0:
			body.velocity.y = -1 * bounce_power
