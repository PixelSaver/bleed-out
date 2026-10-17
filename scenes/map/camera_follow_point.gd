extends Node2D


@export var camera_limits: Vector2 = Vector2(-1000, 1000)

func _process(delta: float) -> void:
	self.global_position.x = clamp(Global.player_ref.global_position.x, camera_limits.x, camera_limits.y)
